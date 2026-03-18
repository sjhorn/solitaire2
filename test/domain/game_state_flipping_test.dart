import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/domain/playing_card.dart';

void main() {
  group('GameState - Flipping', () {
    group('flipTableauCard', () {
      test('reveals face-down card when top face-up card removed', () {
        final king = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.king,
          faceUp: true,
        );
        final queen = PlayingCard(
          suit: CardSuit.spades,
          rank: CardRank.queen,
          faceUp: false,
        );
        final jack = PlayingCard(
          suit: CardSuit.diamonds,
          rank: CardRank.jack,
          faceUp: true,
        );

        final tableauPiles = List.generate(
          7,
          (index) => GamePile(type: PileType.tableau),
        );
        tableauPiles[0].addCard(king);
        tableauPiles[0].addCard(queen);
        tableauPiles[0].addCard(jack);

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

        final newState = state.flipTableauCard(0);

        expect(newState, isNotNull);
        expect(newState!.tableauPiles[0].cards, hasLength(2));
        // King stays face-up
        expect(newState.tableauPiles[0].cards[0].faceUp, isTrue);
        // Queen is revealed face-up
        expect(newState.tableauPiles[0].cards[1].faceUp, isTrue);
        // Queen's suit and rank preserved
        expect(newState.tableauPiles[0].cards[1].suit, equals(CardSuit.spades));
        expect(newState.tableauPiles[0].cards[1].rank, equals(CardRank.queen));
      });

      test('returns null when pile is empty', () {
        final tableauPiles = List.generate(
          7,
          (index) => GamePile(type: PileType.tableau),
        );

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

        final newState = state.flipTableauCard(0);
        expect(newState, isNull);
      });

      test('returns null when top card is already face-down', () {
        final card = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.ace,
          faceUp: false,
        );

        final tableauPiles = List.generate(
          7,
          (index) => GamePile(type: PileType.tableau),
        );
        tableauPiles[0].addCard(card);

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

        final newState = state.flipTableauCard(0);
        expect(newState, isNull);
      });

      test('returns null when only one card in pile', () {
        final card = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.ace,
          faceUp: true,
        );

        final tableauPiles = List.generate(
          7,
          (index) => GamePile(type: PileType.tableau),
        );
        tableauPiles[0].addCard(card);

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

        final newState = state.flipTableauCard(0);
        expect(newState, isNull);
      });

      test('preserves isSelected flag when flipping card', () {
        final king = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.king,
          faceUp: true,
        );
        final queen = PlayingCard(
          suit: CardSuit.spades,
          rank: CardRank.queen,
          faceUp: false,
          isSelected: true,
        );
        final jack = PlayingCard(
          suit: CardSuit.diamonds,
          rank: CardRank.jack,
          faceUp: true,
        );

        final tableauPiles = List.generate(
          7,
          (index) => GamePile(type: PileType.tableau),
        );
        tableauPiles[0].addCard(king);
        tableauPiles[0].addCard(queen);
        tableauPiles[0].addCard(jack);

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

        final newState = state.flipTableauCard(0);

        expect(newState, isNotNull);
        // Queen's isSelected flag is preserved
        expect(newState!.tableauPiles[0].cards[1].isSelected, isTrue);
      });
    });

    group('flipWasteCard', () {
      test('flips face-up waste card to face-down', () {
        final card = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.ace,
          faceUp: true,
        );

        final wastePile = GamePile(type: PileType.waste);
        wastePile.addCard(card);

        final state = GameState.createWithPiles(
          deck: Deck(),
          tableauPiles: List.generate(
            7,
            (index) => GamePile(type: PileType.tableau),
          ),
          foundationPiles: List.generate(
            4,
            (index) => GamePile(type: PileType.foundations),
          ),
          stockPile: GamePile(type: PileType.stock),
          wastePile: wastePile,
        );

        final newState = state.flipWasteCard();

        expect(newState, isNotNull);
        expect(newState!.wastePile.cards, hasLength(1));
        expect(newState.wastePile.topCardThrow.faceUp, isFalse);
        // Suit and rank preserved
        expect(newState.wastePile.topCardThrow.suit, equals(CardSuit.hearts));
        expect(newState.wastePile.topCardThrow.rank, equals(CardRank.ace));
      });

      test('flips face-down waste card to face-up', () {
        final card = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.ace,
          faceUp: false,
        );

        final wastePile = GamePile(type: PileType.waste);
        wastePile.addCard(card);

        final state = GameState.createWithPiles(
          deck: Deck(),
          tableauPiles: List.generate(
            7,
            (index) => GamePile(type: PileType.tableau),
          ),
          foundationPiles: List.generate(
            4,
            (index) => GamePile(type: PileType.foundations),
          ),
          stockPile: GamePile(type: PileType.stock),
          wastePile: wastePile,
        );

        final newState = state.flipWasteCard();

        expect(newState, isNotNull);
        expect(newState!.wastePile.topCardThrow.faceUp, isTrue);
      });

      test('returns null when waste pile is empty', () {
        final state = GameState.createWithPiles(
          deck: Deck(),
          tableauPiles: List.generate(
            7,
            (index) => GamePile(type: PileType.tableau),
          ),
          foundationPiles: List.generate(
            4,
            (index) => GamePile(type: PileType.foundations),
          ),
          stockPile: GamePile(type: PileType.stock),
          wastePile: GamePile(type: PileType.waste),
        );

        final newState = state.flipWasteCard();
        expect(newState, isNull);
      });
    });
  });
}
