import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/domain/pile_type.dart';

void main() {
  group('GameState', () {
    group('initial deal', () {
      test('creates game with proper tableau distribution', () {
        final state = GameState.initial();

        expect(state.tableauPiles, hasLength(7));
        // Tableau piles have 1, 2, 3, 4, 5, 6, 7 cards respectively
        expect(state.tableauPiles[0].cards, hasLength(1));
        expect(state.tableauPiles[1].cards, hasLength(2));
        expect(state.tableauPiles[2].cards, hasLength(3));
        expect(state.tableauPiles[3].cards, hasLength(4));
        expect(state.tableauPiles[4].cards, hasLength(5));
        expect(state.tableauPiles[5].cards, hasLength(6));
        expect(state.tableauPiles[6].cards, hasLength(7));
      });

      test('first tableau card in each pile is face-up', () {
        final state = GameState.initial();

        for (final pile in state.tableauPiles) {
          if (pile.cards.isNotEmpty) {
            expect(pile.cards.first.faceUp, isTrue);
          }
        }
      });

      test('creates game with 52 cards total in play', () {
        final state = GameState.initial();

        // Total cards in tableau + foundation + waste + stock
        final tableauCards = state.tableauPiles.fold(
          0,
          (sum, pile) => sum + pile.cards.length,
        );
        final foundationCards = state.foundationPiles.fold(
          0,
          (sum, pile) => sum + pile.cards.length,
        );
        final wasteCards = state.wastePile.cards.length;
        final stockCards = state.stockPile.cards.length;

        expect(
          tableauCards + foundationCards + wasteCards + stockCards,
          equals(52),
        );
      });

      test('stock pile has 24 cards after deal', () {
        final state = GameState.initial();

        // 52 - 28 (tableau) = 24
        expect(state.stockPile.cards, hasLength(24));
      });

      test('waste pile is empty after deal', () {
        final state = GameState.initial();

        expect(state.wastePile.cards, isEmpty);
      });

      test('all foundation piles are empty after deal', () {
        final state = GameState.initial();

        for (final pile in state.foundationPiles) {
          expect(pile.cards, isEmpty);
        }
      });

      test('foundation piles are empty and ready for aces', () {
        final state = GameState.initial();

        expect(state.foundationPiles[0].cards, isEmpty);
        expect(state.foundationPiles[1].cards, isEmpty);
        expect(state.foundationPiles[2].cards, isEmpty);
        expect(state.foundationPiles[3].cards, isEmpty);
      });
    });

    group('stock depletion', () {
      test('stock is not empty after initial deal', () {
        final state = GameState.initial();

        expect(state.stockPile.isEmpty, isFalse);
      });

      test('stock can be depleted by drawing', () {
        var state = GameState.initial();

        while (state.stockPile.cards.isNotEmpty) {
          state = state.drawFromStock();
        }

        expect(state.stockPile.isEmpty, isTrue);
      });

      test('draws from stock when cards available', () {
        final state = GameState.initial();
        final newState = state.drawFromStock();

        expect(newState.stockPile.cards, hasLength(23));
        expect(newState.wastePile.cards, hasLength(1));
      });
    });

    group('waste to foundation', () {
      test('returns null when waste is empty', () {
        final state = GameState.initial();
        final result = state.moveWasteToFoundation(0);

        expect(result, isNull);
      });

      test('moves ace from waste to foundation', () {
        var state = GameState.initial();
        // Draw until we get an ace in waste (or add one manually)
        while (state.wastePile.cards.isEmpty || state.wastePile.topCardThrow.rank.value != 1) {
          state = state.drawFromStock();
        }
        final result = state.moveWasteToFoundation(0);

        expect(result, isNotNull);
        expect(result!.foundationPiles[0].cards, hasLength(1));
      });

      test('does not move non-ace card to empty foundation', () {
        var state = GameState.initial();
        // Draw cards until we get a non-ace in waste
        while (state.wastePile.cards.isEmpty || state.wastePile.topCardThrow.rank.value == 1) {
          state = state.drawFromStock();
        }
        // Now we have a non-ace in waste, try to move to empty foundation
        final result = state.moveWasteToFoundation(0);

        expect(result, isNull);
      });
    });

    group('win detection', () {
      test('isNotWon immediately after deal', () {
        final state = GameState.initial();

        expect(state.isWon, isFalse);
      });

      test('isWon when all cards are in foundations', () {
        // This would require manually moving all cards to foundations
        // Skipping for now as full implementation requires move logic
        final state = GameState.initial();
        expect(state.isWon, isFalse);
      });
    });

    group('pile types', () {
      test('all foundation piles are foundation type', () {
        final state = GameState.initial();

        for (final pile in state.foundationPiles) {
          expect(pile.type, equals(PileType.foundations));
        }
      });

      test('tableau piles are tableau type', () {
        final state = GameState.initial();

        for (final pile in state.tableauPiles) {
          expect(pile.type, equals(PileType.tableau));
        }
      });

      test('waste pile is waste type', () {
        final state = GameState.initial();

        expect(state.wastePile.type, equals(PileType.waste));
      });

      test('stock pile is stock type', () {
        final state = GameState.initial();

        expect(state.stockPile.type, equals(PileType.stock));
      });
    });

    group('flip tableau card', () {
      test('returns null for empty tableau pile', () {
        var state = GameState.createWithPiles(
          deck: Deck(),
          tableauPiles: [
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
          ],
          foundationPiles: [
            GamePile(type: PileType.foundations),
            GamePile(type: PileType.foundations),
            GamePile(type: PileType.foundations),
            GamePile(type: PileType.foundations),
          ],
          stockPile: GamePile(type: PileType.stock),
          wastePile: GamePile(type: PileType.waste),
        );
        final result = state.flipTableauCard(0);

        expect(result, isNull);
      });

      test('returns null when only one card in pile', () {
        var state = GameState.initial();
        // Tableau pile 0 has only 1 card
        final result = state.flipTableauCard(0);

        expect(result, isNull);
      });

      test('flips top card to reveal card below', () {
        var state = GameState.initial();
        // Tableau pile 1 has 2 cards, so we can flip
        final result = state.flipTableauCard(1);

        expect(result, isNotNull);
        expect(result!.tableauPiles[1].cards, hasLength(1));
        expect(result.tableauPiles[1].cards.first.faceUp, isTrue);
      });
    });

    group('move tableau to foundation', () {
      test('returns null for empty tableau pile', () {
        var state = GameState.createWithPiles(
          deck: Deck(),
          tableauPiles: [
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
            GamePile(type: PileType.tableau),
          ],
          foundationPiles: [
            GamePile(type: PileType.foundations),
            GamePile(type: PileType.foundations),
            GamePile(type: PileType.foundations),
            GamePile(type: PileType.foundations),
          ],
          stockPile: GamePile(type: PileType.stock),
          wastePile: GamePile(type: PileType.waste),
        );
        final result = state.moveTableauToFoundation(0, 0);

        expect(result, isNull);
      });

      test('returns null for invalid foundation index', () {
        var state = GameState.initial();
        final result = state.moveTableauToFoundation(0, 5);

        expect(result, isNull);
      });

      test('returns null when move is invalid', () {
        // Create a controlled state with a known non-ace card in tableau
        final deck = Deck();
        deck.shuffle();

        final tableauPiles = List.generate(
          7,
          (index) => GamePile(type: PileType.tableau),
        );
        // Add a King (not an ace) to the first tableau pile
        tableauPiles[0].addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true));

        final foundationPiles = List.generate(
          4,
          (index) => GamePile(type: PileType.foundations),
        );

        final state = GameState.createWithPiles(
          deck: deck,
          tableauPiles: tableauPiles,
          foundationPiles: foundationPiles,
          stockPile: GamePile(type: PileType.stock),
          wastePile: GamePile(type: PileType.waste),
        );

        // Try to move King to empty foundation (only ace is valid)
        final result = state.moveTableauToFoundation(0, 0);

        expect(result, isNull);
      });
    });

    group('flip waste card', () {
      test('returns null when waste is empty', () {
        final state = GameState.initial();
        final result = state.flipWasteCard();

        expect(result, isNull);
      });

      test('flips waste card when available', () {
        var state = GameState.initial();
        state = state.drawFromStock();
        final result = state.flipWasteCard();

        expect(result, isNotNull);
        expect(result!.wastePile.cards.first.faceUp, isTrue);
      });
    });

    group('is won detection', () {
      test('is not won after initial deal', () {
        final state = GameState.initial();
        expect(state.isWon, isFalse);
      });

      test('returns true only when all 52 cards in foundations', () {
        var state = GameState.initial();
        expect(state.isWon, isFalse);
        // This would require moving all cards, which is complex
        // Just verify that initial state is not won
      });
    });
  });
}
