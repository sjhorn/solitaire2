import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/playing_card.dart';

/// Types of hints that can be provided to the player.
enum HintType {
  wasteToFoundation,
  tableauToFoundation,
  wasteToTableau,
  foundationToTableau,
  tableauToTableau,
}

/// A hint representing a valid move the player can make.
class Hint {
  final HintType type;
  final int? tableauIndex;
  final int? targetTableauIndex;
  final int? foundationsIndex;

  Hint({
    required this.type,
    this.tableauIndex,
    this.targetTableauIndex,
    this.foundationsIndex,
  });
}

/// Extension on CardSuit to check if a suit is red or black.
extension CardSuitColor on CardSuit {
  bool get isRed => this == CardSuit.hearts || this == CardSuit.diamonds;
  bool get isBlack => this == CardSuit.spades || this == CardSuit.clubs;
}

/// Extension on GamePile to provide convenient access to pile properties.
extension GamePileExtensions on GamePile {
  bool get isEmpty => cards.isEmpty;
  PlayingCard get topCardThrow => cards.last;
}

/// Service that analyzes game state and provides hints for valid moves.
class HintService {
  List<Hint> findHints(GameState gameState) {
    final hints = <Hint>[];

    // Check waste to foundation moves
    if (gameState.wastePile.isEmpty == false) {
      final wasteCard = gameState.wastePile.topCardThrow;
      for (var i = 0; i < gameState.foundationPiles.length; i++) {
        if (_canMoveWasteToFoundation(wasteCard, gameState.foundationPiles[i])) {
          hints.add(Hint(
            type: HintType.wasteToFoundation,
            foundationsIndex: i,
          ));
        }
      }
    }

    // Check tableau to foundation moves
    for (var tableauIndex = 0; tableauIndex < gameState.tableauPiles.length; tableauIndex++) {
      final tableau = gameState.tableauPiles[tableauIndex];
      if (tableau.isEmpty) continue;

      final card = tableau.topCardThrow;
      for (var foundationIndex = 0; foundationIndex < gameState.foundationPiles.length; foundationIndex++) {
        if (_canMoveToFoundation(card, gameState.foundationPiles[foundationIndex])) {
          hints.add(Hint(
            type: HintType.tableauToFoundation,
            tableauIndex: tableauIndex,
            foundationsIndex: foundationIndex,
          ));
        }
      }
    }

    // Check waste to tableau moves
    if (gameState.wastePile.isEmpty == false) {
      final wasteCard = gameState.wastePile.topCardThrow;
      for (var i = 0; i < gameState.tableauPiles.length; i++) {
        if (_canMoveToTableau(wasteCard, gameState.tableauPiles[i])) {
          hints.add(Hint(
            type: HintType.wasteToTableau,
            tableauIndex: i,
          ));
        }
      }
    }

    // Check foundation to tableau moves
    for (var foundationIndex = 0; foundationIndex < gameState.foundationPiles.length; foundationIndex++) {
      final foundation = gameState.foundationPiles[foundationIndex];
      if (foundation.isEmpty) continue;

      final card = foundation.topCardThrow;
      for (var tableauIndex = 0; tableauIndex < gameState.tableauPiles.length; tableauIndex++) {
        if (_canMoveToTableau(card, gameState.tableauPiles[tableauIndex])) {
          hints.add(Hint(
            type: HintType.foundationToTableau,
            foundationsIndex: foundationIndex,
            tableauIndex: tableauIndex,
          ));
        }
      }
    }

    // Check tableau to tableau moves
    for (var fromIndex = 0; fromIndex < gameState.tableauPiles.length; fromIndex++) {
      final fromTableau = gameState.tableauPiles[fromIndex];
      if (fromTableau.isEmpty) continue;

      final card = fromTableau.topCardThrow;
      for (var toIndex = 0; toIndex < gameState.tableauPiles.length; toIndex++) {
        if (fromIndex == toIndex) continue;
        if (_canMoveToTableau(card, gameState.tableauPiles[toIndex])) {
          hints.add(Hint(
            type: HintType.tableauToTableau,
            tableauIndex: fromIndex,
            targetTableauIndex: toIndex,
          ));
        }
      }
    }

    return hints;
  }

  bool _canMoveToFoundation(PlayingCard card, GamePile foundation) {
    if (foundation.isEmpty) {
      return card.rank == CardRank.ace;
    }
    final topCard = foundation.topCardThrow;
    return card.suit == topCard.suit && card.rank.value == topCard.rank.value + 1;
  }

  bool _canMoveWasteToFoundation(PlayingCard card, GamePile foundation) {
    return _canMoveToFoundation(card, foundation);
  }

  bool _canMoveToTableau(PlayingCard card, GamePile tableau) {
    if (tableau.isEmpty) {
      return card.rank == CardRank.king;
    }
    final topCard = tableau.topCardThrow;
    final isOppositeColor = (card.suit.isRed && topCard.suit.isBlack) ||
        (card.suit.isBlack && topCard.suit.isRed);
    return isOppositeColor && card.rank.value == topCard.rank.value - 1;
  }
}
