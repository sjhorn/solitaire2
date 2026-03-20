import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/domain/playing_card.dart';

/// The complete state of a Klondike Solitaire game.
class GameState {
  final Deck _deck;
  final GamePile _stockPile;
  final GamePile _wastePile;
  final List<GamePile> _foundationPiles;
  final List<GamePile> _tableauPiles;

  GameState._({
    required Deck deck,
    required GamePile stockPile,
    required GamePile wastePile,
    required List<GamePile> foundationPiles,
    required List<GamePile> tableauPiles,
  }) : _deck = deck,
       _stockPile = stockPile,
       _wastePile = wastePile,
       _foundationPiles = List.unmodifiable(foundationPiles),
       _tableauPiles = List.unmodifiable(tableauPiles);

  /// Creates the initial game state with a full deal.
  factory GameState.initial() {
    final deck = Deck();
    deck.shuffle();

    final stockPile = GamePile(type: PileType.stock);
    final wastePile = GamePile(type: PileType.waste);
    final foundationPiles = List.generate(
      4,
      (index) => GamePile(type: PileType.foundations),
    );
    final tableauPiles = List.generate(
      7,
      (index) => GamePile(type: PileType.tableau),
    );

    // Deal 1-7 cards to tableau piles (top card face-up)
    for (var i = 0; i < 7; i++) {
      for (var j = 0; j <= i; j++) {
        final card = deck.draw();
        tableauPiles[i].addCard(
          j == i ? card.copyWith(faceUp: true) : card.copyWith(faceUp: false),
        );
      }
    }

    // Rest goes to stock
    while (deck.cards.isNotEmpty) {
      stockPile.addCard(deck.draw());
    }

    return GameState._(
      deck: deck,
      stockPile: stockPile,
      wastePile: wastePile,
      foundationPiles: foundationPiles,
      tableauPiles: tableauPiles,
    );
  }

  /// Creates a GameState for testing purposes.
  ///
  /// This factory method allows tests to create a controlled game state
  /// with specific cards in specific positions without relying on random deals.
  factory GameState.createWithPiles({
    required Deck deck,
    required List<GamePile> tableauPiles,
    required List<GamePile> foundationPiles,
    required GamePile stockPile,
    required GamePile wastePile,
  }) {
    return GameState._(
      deck: deck,
      stockPile: stockPile,
      wastePile: wastePile,
      foundationPiles: List.unmodifiable(foundationPiles),
      tableauPiles: List.unmodifiable(tableauPiles),
    );
  }

  Deck get deck => _deck;
  GamePile get stockPile => _stockPile;
  GamePile get wastePile => _wastePile;
  List<GamePile> get foundationPiles => _foundationPiles;
  List<GamePile> get tableauPiles => _tableauPiles;

  bool get isWon {
    // Win when all 52 cards are in foundations
    final foundationCards = _foundationPiles.fold(
      0,
      (sum, pile) => sum + pile.cards.length,
    );
    return foundationCards == 52;
  }

  /// Draws a card from the stock to the waste.
  GameState drawFromStock() {
    if (_stockPile.isEmpty) {
      // Recycle waste to stock
      final newStock = GamePile(type: PileType.stock);
      while (_wastePile.cards.isNotEmpty) {
        final card = _wastePile.removeTopCard();
        newStock.addCard(
          PlayingCard(suit: card.suit, rank: card.rank, faceUp: false),
        );
      }

      return GameState._(
        deck: _deck,
        stockPile: newStock,
        wastePile: GamePile(type: PileType.waste),
        foundationPiles: List.unmodifiable(_foundationPiles),
        tableauPiles: List.unmodifiable(_tableauPiles),
      );
    }

    final card = _stockPile.removeTopCard();
    final newWaste = GamePile(type: PileType.waste);
    newWaste.addCard(card.copyWith(faceUp: false));

    return GameState._(
      deck: _deck,
      stockPile: _stockPile,
      wastePile: newWaste,
      foundationPiles: List.unmodifiable(_foundationPiles),
      tableauPiles: List.unmodifiable(_tableauPiles),
    );
  }

  /// Tries to move the top waste card to a foundation.
  GameState? moveWasteToFoundation(int foundationIndex) {
    if (_wastePile.isEmpty) return null;

    final card = _wastePile.topCardThrow;
    final foundation = _foundationPiles[foundationIndex];

    if (_isValidFoundationMove(card, foundation)) {
      final newWaste = GamePile(type: PileType.waste);
      newWaste.addCards(_wastePile.cards);
      newWaste.removeTopCard();

      final newFoundation = GamePile(type: PileType.foundations);
      newFoundation.addCards(foundation.cards);
      newFoundation.addCard(card);

      return GameState._(
        deck: _deck,
        stockPile: _stockPile,
        wastePile: newWaste,
        foundationPiles: List.generate(
          4,
          (i) => i == foundationIndex ? newFoundation : _foundationPiles[i],
        ),
        tableauPiles: List.unmodifiable(_tableauPiles),
      );
    }

    return null;
  }

  bool _isValidFoundationMove(PlayingCard card, GamePile foundation) {
    if (foundation.isEmpty) {
      return card.rank.value == 1; // Ace
    }

    final topCard = foundation.topCardThrow;
    return card.suit == topCard.suit &&
        card.rank.value == topCard.rank.value + 1;
  }

  /// Tries to move a card from tableau to foundation.
  GameState? moveTableauToFoundation(int tableauIndex, int foundationIndex) {
    if (foundationIndex < 0 || foundationIndex >= _foundationPiles.length) {
      return null;
    }

    final tableau = _tableauPiles[tableauIndex];
    if (tableau.isEmpty) return null;

    final card = tableau.topCardThrow;
    final foundation = _foundationPiles[foundationIndex];

    if (_isValidFoundationMove(card, foundation)) {
      final newTableau = GamePile(type: PileType.tableau);
      newTableau.addCards(tableau.cards);
      newTableau.removeTopCard();

      final newFoundation = GamePile(type: PileType.foundations);
      newFoundation.addCards(foundation.cards);
      newFoundation.addCard(card);

      return GameState._(
        deck: _deck,
        stockPile: _stockPile,
        wastePile: _wastePile,
        foundationPiles: List.generate(
          4,
          (i) => i == foundationIndex ? newFoundation : _foundationPiles[i],
        ),
        tableauPiles: List.generate(
          7,
          (i) => i == tableauIndex ? newTableau : _tableauPiles[i],
        ),
      );
    }

    return null;
  }

  /// Flips the top card of a tableau pile.
  ///
  /// Removes the top face-up card and reveals (flips face-up) the card below it.
  GameState? flipTableauCard(int tableauIndex) {
    final tableau = _tableauPiles[tableauIndex];
    if (tableau.isEmpty) return null;

    if (!tableau.topCardThrow.faceUp) {
      return null; // Can't flip if top card is already face-down
    }

    // Check if there are more cards below
    if (tableau.cards.length <= 1) return null;

    // Build new list: keep all cards except the top one (king),
    // and flip the new top card (queen) face-up
    final cards = tableau.cards;
    final newCards = <PlayingCard>[];
    for (var i = 0; i < cards.length - 1; i++) {
      newCards.add(cards[i]);
    }

    // Flip the card that is now on top (was second-to-last)
    final newTopCard = PlayingCard(
      suit: newCards.last.suit,
      rank: newCards.last.rank,
      faceUp: true,
      isSelected: newCards.last.isSelected,
    );

    // Remove the old (unflipped) second-to-last and add the flipped version
    newCards.removeLast();
    newCards.add(newTopCard);

    final newTableau = GamePile(type: PileType.tableau);
    newTableau.addCards(newCards);

    return GameState._(
      deck: _deck,
      stockPile: _stockPile,
      wastePile: _wastePile,
      foundationPiles: List.unmodifiable(_foundationPiles),
      tableauPiles: List.generate(
        7,
        (i) => i == tableauIndex ? newTableau : _tableauPiles[i],
      ),
    );
  }

  /// Flips the top waste card.
  GameState? flipWasteCard() {
    if (_wastePile.isEmpty) return null;

    final card = _wastePile.topCardThrow;
    // Build new waste pile with flipped card
    final newCards = <PlayingCard>[];
    for (var i = 0; i < _wastePile.cards.length - 1; i++) {
      newCards.add(_wastePile.cards[i]);
    }
    // Add flipped card
    newCards.add(
      PlayingCard(
        suit: card.suit,
        rank: card.rank,
        faceUp: !card.faceUp,
        isSelected: card.isSelected,
      ),
    );

    final newWaste = GamePile(type: PileType.waste);
    newWaste.addCards(newCards);

    return GameState._(
      deck: _deck,
      stockPile: _stockPile,
      wastePile: newWaste,
      foundationPiles: List.unmodifiable(_foundationPiles),
      tableauPiles: List.unmodifiable(_tableauPiles),
    );
  }

  /// Tries to move a card from waste to a tableau pile.
  GameState? moveWasteToTableau(int tableauIndex) {
    if (_wastePile.isEmpty) return null;

    final card = _wastePile.topCardThrow;
    final tableau = _tableauPiles[tableauIndex];

    if (_isValidTableauMove(card, tableau)) {
      final newWaste = GamePile(type: PileType.waste);
      newWaste.addCards(_wastePile.cards);
      newWaste.removeTopCard();

      final newTableau = GamePile(type: PileType.tableau);
      newTableau.addCards(tableau.cards);
      newTableau.addCard(card);

      // Flip the new top card of the tableau if it was face-down
      if (newTableau.cards.isNotEmpty && !newTableau.topCardThrow.faceUp) {
        // This would require calling flipTableauCard logic here
      }

      return GameState._(
        deck: _deck,
        stockPile: _stockPile,
        wastePile: newWaste,
        foundationPiles: List.unmodifiable(_foundationPiles),
        tableauPiles: List.generate(
          7,
          (i) => i == tableauIndex ? newTableau : _tableauPiles[i],
        ),
      );
    }

    return null;
  }

  /// Tries to move a card from foundation to a tableau pile.
  GameState? moveFoundationToTableau(int foundationIndex, int tableauIndex) {
    final foundation = _foundationPiles[foundationIndex];
    if (foundation.isEmpty) return null;

    final card = foundation.topCardThrow;
    final tableau = _tableauPiles[tableauIndex];

    if (_isValidTableauMove(card, tableau)) {
      final newFoundation = GamePile(type: PileType.foundations);
      newFoundation.addCards(foundation.cards);
      newFoundation.removeTopCard();

      final newTableau = GamePile(type: PileType.tableau);
      newTableau.addCards(tableau.cards);
      newTableau.addCard(card);

      return GameState._(
        deck: _deck,
        stockPile: _stockPile,
        wastePile: _wastePile,
        foundationPiles: List.generate(
          4,
          (i) => i == foundationIndex ? newFoundation : _foundationPiles[i],
        ),
        tableauPiles: List.generate(
          7,
          (i) => i == tableauIndex ? newTableau : _tableauPiles[i],
        ),
      );
    }

    return null;
  }

  /// Tries to move cards from one tableau pile to another.
  GameState? moveTableauToTableau(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return null;

    final fromTableau = _tableauPiles[fromIndex];
    if (fromTableau.isEmpty) return null;

    final card = fromTableau.topCardThrow;
    final toTableau = _tableauPiles[toIndex];

    if (_isValidTableauMove(card, toTableau)) {
      // Get the stack of face-up cards to move
      final stackToMove = _getFaceUpStack(fromTableau);

      final newFromTableau = GamePile(type: PileType.tableau);
      // Keep cards that aren't being moved
      for (var i = 0; i < fromTableau.cards.length - stackToMove.length; i++) {
        newFromTableau.addCard(fromTableau.cards[i]);
      }

      final newToTableau = GamePile(type: PileType.tableau);
      newToTableau.addCards(toTableau.cards);
      for (final moveCard in stackToMove) {
        newToTableau.addCard(moveCard);
      }

      return GameState._(
        deck: _deck,
        stockPile: _stockPile,
        wastePile: _wastePile,
        foundationPiles: List.unmodifiable(_foundationPiles),
        tableauPiles: List.generate(
          7,
          (i) => i == fromIndex
              ? newFromTableau
              : i == toIndex
                  ? newToTableau
                  : _tableauPiles[i],
        ),
      );
    }

    return null;
  }

  /// Returns all consecutive face-up cards from the top of a tableau pile.
  List<PlayingCard> _getFaceUpStack(GamePile pile) {
    final stack = <PlayingCard>[];
    for (var i = pile.cards.length - 1; i >= 0; i--) {
      if (pile.cards[i].faceUp) {
        stack.insert(0, pile.cards[i]);
      } else {
        break;
      }
    }
    return stack;
  }

  bool _isValidTableauMove(PlayingCard card, GamePile tableau) {
    if (tableau.isEmpty) {
      return card.rank == CardRank.king;
    }

    final topCard = tableau.topCardThrow;

    // Must be opposite color and descending rank
    final isOppositeColor = (card.suit.isRed && topCard.suit.isBlack) ||
        (card.suit.isBlack && topCard.suit.isRed);
    return isOppositeColor && card.rank.value == topCard.rank.value - 1;
  }
}

extension on CardSuit {
  bool get isRed => this == CardSuit.hearts || this == CardSuit.diamonds;
  bool get isBlack => this == CardSuit.spades || this == CardSuit.clubs;
}
