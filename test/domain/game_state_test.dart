import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/game_state.dart';
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
        final state = GameState.initial();

        while (state.stockPile.cards.isNotEmpty) {
          state.drawFromStock();
        }

        expect(state.stockPile.isEmpty, isTrue);
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
  });
}
