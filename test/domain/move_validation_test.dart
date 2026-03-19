import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/domain/playing_card.dart';

void main() {
  group('Move Validation - Tableau to Foundation', () {
    test('allows moving Ace to empty foundation', () {
      // Create a controlled state with Ace on top of tableau
      final deck = Deck();
      deck.shuffle();

      // Use a known Ace card
      final aceCard = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      // Put only an Ace in the first tableau pile
      tableauPiles[0].addCard(aceCard);

      final state = GameState.createWithPiles(
        deck: deck,
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(
          4,
          (index) => GamePile(type: PileType.foundations),
        ),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveTableauToFoundation(0, 0);
      expect(newState, isNotNull);
      expect(newState?.foundationPiles[0].cards, hasLength(1));
      expect(
        newState?.foundationPiles[0].topCardThrow.rank,
        equals(CardRank.ace),
      );
    });

    test('allows moving 2 of hearts to Ace of hearts in foundation', () {
      final aceCard = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
      final twoCard = PlayingCard(suit: CardSuit.hearts, rank: CardRank.two);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(twoCard);

      final foundationPiles = List.generate(
        4,
        (index) => GamePile(type: PileType.foundations),
      );
      foundationPiles[0].addCard(aceCard);

      final deck = Deck();

      final state = GameState.createWithPiles(
        deck: deck,
        tableauPiles: tableauPiles,
        foundationPiles: foundationPiles,
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveTableauToFoundation(0, 0);
      expect(newState, isNotNull);
      expect(newState?.foundationPiles[0].cards, hasLength(2));
    });

    test('does not allow moving King to empty foundation', () {
      final kingCard = PlayingCard(suit: CardSuit.spades, rank: CardRank.king);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(kingCard);

      final foundationPiles = List.generate(
        4,
        (index) => GamePile(type: PileType.foundations),
      );

      final deck = Deck();

      final state = GameState.createWithPiles(
        deck: deck,
        tableauPiles: tableauPiles,
        foundationPiles: foundationPiles,
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveTableauToFoundation(0, 0);
      expect(newState, isNull);
    });

    test('does not allow moving wrong suit to foundation with Ace', () {
      final aceCard = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
      final spadeCard = PlayingCard(suit: CardSuit.spades, rank: CardRank.two);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(spadeCard);

      final foundationPiles = List.generate(
        4,
        (index) => GamePile(type: PileType.foundations),
      );
      foundationPiles[0].addCard(aceCard);

      final deck = Deck();

      final state = GameState.createWithPiles(
        deck: deck,
        tableauPiles: tableauPiles,
        foundationPiles: foundationPiles,
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveTableauToFoundation(0, 0);
      expect(newState, isNull);
    });
  });

  group('Move Validation - Stock to Waste', () {
    test('draws card from stock to waste', () {
      final state = GameState.initial();
      final originalStockCount = state.stockPile.cards.length;
      final originalWasteCount = state.wastePile.cards.length;

      final newState = state.drawFromStock();

      expect(newState.stockPile.cards.length, equals(originalStockCount - 1));
      expect(newState.wastePile.cards.length, equals(originalWasteCount + 1));
    });

    test('recycles waste to stock when stock is empty', () {
      final state = GameState.initial();

      GameState? testState = state;
      while (testState!.stockPile.cards.isNotEmpty) {
        testState = testState.drawFromStock();
      }

      expect(testState.stockPile.isEmpty, isTrue);

      final recycledState = testState.drawFromStock();

      expect(recycledState.stockPile.isEmpty, isFalse);
      expect(recycledState.wastePile.isEmpty, isTrue);
    });
  });

  group('Move Validation - Face-down to Face-up', () {
    test('reveals face-down card when top card moved from tableau', () {
      // Setup: 3 cards where top card is face-up and can be removed,
      // second card is face-up but stays, bottom card is face-down and will be revealed
      final card1 = PlayingCard(
        suit: CardSuit.hearts,
        rank: CardRank.king,
        faceUp: true,
      );
      final card2 = PlayingCard(
        suit: CardSuit.spades,
        rank: CardRank.queen,
        faceUp: false,
      );
      final card3 = PlayingCard(
        suit: CardSuit.diamonds,
        rank: CardRank.jack,
        faceUp: true,
      );

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(card1);
      tableauPiles[0].addCard(card2);
      tableauPiles[0].addCard(card3);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(
          4,
          (index) => GamePile(type: PileType.foundations),
        ),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      // flipTableauCard removes jack (top), flips queen face-up
      final newState = state.flipTableauCard(0);
      expect(newState, isNotNull);
      expect(newState?.tableauPiles[0].cards, hasLength(2));
      expect(
        newState?.tableauPiles[0].cards[0].faceUp,
        isTrue,
      ); // king stays face-up
      expect(
        newState?.tableauPiles[0].cards[1].faceUp,
        isTrue,
      ); // queen is now revealed face-up
    });
  });

  group('Move Validation - Waste to Tableau', () {
    test('moves waste card to empty tableau when King', () {
      final kingCard = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );

      final foundationPiles = List.generate(
        4,
        (index) => GamePile(type: PileType.foundations),
      );

      final stockPile = GamePile(type: PileType.stock);
      final wastePile = GamePile(type: PileType.waste)..addCard(kingCard);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: foundationPiles,
        stockPile: stockPile,
        wastePile: wastePile,
      );

      final newState = state.moveWasteToTableau(0);
      expect(newState, isNotNull);
      expect(newState?.wastePile.isEmpty, isTrue);
      expect(newState?.tableauPiles[0].cards, hasLength(1));
      expect(newState?.tableauPiles[0].topCardThrow.rank, CardRank.king);
    });

    test('does not move non-King to empty tableau', () {
      final queenCard = PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste)..addCard(queenCard),
      );

      final newState = state.moveWasteToTableau(0);
      expect(newState, isNull);
    });

    test('moves card to tableau with alternating color and descending rank', () {
      final kingCard = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);
      final queenHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(kingCard);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste)..addCard(queenHearts),
      );

      final newState = state.moveWasteToTableau(0);
      expect(newState, isNotNull);
      expect(newState?.tableauPiles[0].cards, hasLength(2));
      expect(newState?.wastePile.isEmpty, isTrue);
    });

    test('does not move card with same color to tableau', () {
      final kingSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);
      final queenSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.queen, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(kingSpades);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste)..addCard(queenSpades),
      );

      final newState = state.moveWasteToTableau(0);
      expect(newState, isNull);
    });

    test('returns null when waste is empty', () {
      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveWasteToTableau(0);
      expect(newState, isNull);
    });
  });

  group('Move Validation - Foundation to Tableau', () {
    test('moves card from foundation to empty tableau when King', () {
      final kingCard = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);

      final foundationPiles = List.generate(
        4,
        (index) => GamePile(type: PileType.foundations),
      );
      foundationPiles[0].addCard(kingCard);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: foundationPiles,
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveFoundationToTableau(0, 0);
      expect(newState, isNotNull);
      expect(newState?.foundationPiles[0].isEmpty, isTrue);
      expect(newState?.tableauPiles[0].cards, hasLength(1));
    });

    test('moves card from foundation to tableau with alternating color', () {
      final kingSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);
      final queenHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true);

      final foundationPiles = List.generate(
        4,
        (index) => GamePile(type: PileType.foundations),
      );
      foundationPiles[0].addCard(queenHearts);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(kingSpades);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: foundationPiles,
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveFoundationToTableau(0, 0);
      expect(newState, isNotNull);
      expect(newState?.foundationPiles[0].isEmpty, isTrue);
      expect(newState?.tableauPiles[0].cards, hasLength(2));
    });

    test('returns null when foundation is empty', () {
      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveFoundationToTableau(0, 0);
      expect(newState, isNull);
    });
  });

  group('Move Validation - Tableau to Tableau', () {
    test('moves single face-up card to tableau with alternating color', () {
      final kingSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);
      final queenHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(kingSpades);
      tableauPiles[1].addCard(queenHearts);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      // Move from tableau 1 to tableau 0
      final newState = state.moveTableauToTableau(1, 0);
      expect(newState, isNotNull);
      expect(newState?.tableauPiles[0].cards, hasLength(2));
      expect(newState?.tableauPiles[1].isEmpty, isTrue);
    });

    test('moves stack of face-up cards to tableau', () {
      final jackSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.jack, faceUp: true);
      final queenHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true);
      final jackClubs = PlayingCard(suit: CardSuit.clubs, rank: CardRank.jack, faceUp: true);
      final tenDiamonds = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.ten, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(jackSpades);
      // Add stack: queen (red), jack (black), ten (red) - all face-up
      tableauPiles[1].addCard(queenHearts);
      tableauPiles[1].addCard(jackClubs);
      tableauPiles[1].addCard(tenDiamonds);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      // Move stack (ten, jack, queen) from tableau 1 to tableau 0 (jack)
      // Ten (red, 10) on Jack (black, 11) is valid - alternating color and descending
      final newState = state.moveTableauToTableau(1, 0);
      expect(newState, isNotNull);
      expect(newState?.tableauPiles[0].cards, hasLength(4));
      expect(newState?.tableauPiles[1].isEmpty, isTrue);
    });

    test('does not move to same tableau', () {
      final kingCard = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(kingCard);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveTableauToTableau(0, 0);
      expect(newState, isNull);
    });

    test('does not move from empty tableau', () {
      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      final newState = state.moveTableauToTableau(0, 1);
      expect(newState, isNull);
    });

    test('does not move invalid card to tableau', () {
      final kingSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);
      final jackSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.jack, faceUp: true);

      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      tableauPiles[0].addCard(kingSpades);
      tableauPiles[1].addCard(jackSpades);

      final state = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: tableauPiles,
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      // Same color - should fail
      final newState = state.moveTableauToTableau(1, 0);
      expect(newState, isNull);
    });
  });
}
