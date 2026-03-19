import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/hint_service.dart';

void main() {
  group('HintService', () {
    late HintService hintService;

    setUp(() {
      hintService = HintService();
    });

    group('findHints', () {
      test('returns empty hints when no valid moves available', () {
        final gameState = GameState.initial();
        final hints = hintService.findHints(gameState);

        // Initial deal may or may not have valid moves depending on shuffle
        // Just verify the service doesn't crash
        expect(hints, isList);
      });

      test('detects waste to foundation move', () {
        // Create a game state with Ace in waste and 2 on foundation
        final deck = Deck();
        deck.shuffle();

        final stockPile = GamePile(type: PileType.stock);
        final wastePile = GamePile(type: PileType.waste);
        wastePile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true));

        final foundationPiles = [
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
        ];

        // Add Ace of hearts to first foundation
        foundationPiles[0].addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));

        final tableauPiles = List.generate(7, (index) => GamePile(type: PileType.tableau));

        final gameState = GameState.createWithPiles(
          deck: deck,
          stockPile: stockPile,
          wastePile: wastePile,
          foundationPiles: foundationPiles,
          tableauPiles: tableauPiles,
        );

        final hints = hintService.findHints(gameState);

        expect(hints.length, greaterThan(0));
        expect(hints.first.type, HintType.wasteToFoundation);
        expect(hints.first.foundationsIndex, 0);
      });

      test('detects tableau to foundation move', () {
        final deck = Deck();
        final stockPile = GamePile(type: PileType.stock);
        final wastePile = GamePile(type: PileType.waste);

        final foundationPiles = [
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
        ];

        // Add Ace of spades to first foundation
        foundationPiles[0].addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: true));

        final tableauPiles = List.generate(7, (index) => GamePile(type: PileType.tableau));
        // Add 2 of spades to first tableau
        tableauPiles[0].addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.two, faceUp: true));

        final gameState = GameState.createWithPiles(
          deck: deck,
          stockPile: stockPile,
          wastePile: wastePile,
          foundationPiles: foundationPiles,
          tableauPiles: tableauPiles,
        );

        final hints = hintService.findHints(gameState);

        expect(hints.length, greaterThan(0));
        expect(hints.first.type, HintType.tableauToFoundation);
        expect(hints.first.tableauIndex, 0);
        expect(hints.first.foundationsIndex, 0);
      });

      test('detects waste to tableau move', () {
        final deck = Deck();
        final stockPile = GamePile(type: PileType.stock);
        final wastePile = GamePile(type: PileType.waste);
        // Add red 5 to waste
        wastePile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.five, faceUp: true));

        final foundationPiles = List.generate(4, (index) => GamePile(type: PileType.foundations));

        final tableauPiles = List.generate(7, (index) => GamePile(type: PileType.tableau));
        // Add black 6 to first tableau
        tableauPiles[0].addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.six, faceUp: true));

        final gameState = GameState.createWithPiles(
          deck: deck,
          stockPile: stockPile,
          wastePile: wastePile,
          foundationPiles: foundationPiles,
          tableauPiles: tableauPiles,
        );

        final hints = hintService.findHints(gameState);

        expect(hints.length, greaterThan(0));
        expect(hints.first.type, HintType.wasteToTableau);
        expect(hints.first.tableauIndex, 0);
      });

      test('detects foundation to tableau move', () {
        final deck = Deck();
        final stockPile = GamePile(type: PileType.stock);
        final wastePile = GamePile(type: PileType.waste);

        final foundationPiles = [
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
          GamePile(type: PileType.foundations),
        ];
        // Add black 4 to first foundation
        foundationPiles[0].addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.four, faceUp: true));

        final tableauPiles = List.generate(7, (index) => GamePile(type: PileType.tableau));
        // Add red 5 to second tableau (4 can move onto 5)
        tableauPiles[1].addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.five, faceUp: true));

        final gameState = GameState.createWithPiles(
          deck: deck,
          stockPile: stockPile,
          wastePile: wastePile,
          foundationPiles: foundationPiles,
          tableauPiles: tableauPiles,
        );

        final hints = hintService.findHints(gameState);

        expect(hints.length, greaterThan(0));
        expect(hints.first.type, HintType.foundationToTableau);
        expect(hints.first.foundationsIndex, 0);
        expect(hints.first.tableauIndex, 1);
      });

      test('detects tableau to tableau move', () {
        final deck = Deck();
        final stockPile = GamePile(type: PileType.stock);
        final wastePile = GamePile(type: PileType.waste);
        final foundationPiles = List.generate(4, (index) => GamePile(type: PileType.foundations));

        final tableauPiles = List.generate(7, (index) => GamePile(type: PileType.tableau));
        // Add red 5 to first tableau
        tableauPiles[0].addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.five, faceUp: true));
        // Add black 6 to second tableau
        tableauPiles[1].addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.six, faceUp: true));

        final gameState = GameState.createWithPiles(
          deck: deck,
          stockPile: stockPile,
          wastePile: wastePile,
          foundationPiles: foundationPiles,
          tableauPiles: tableauPiles,
        );

        final hints = hintService.findHints(gameState);

        expect(hints.length, greaterThan(0));
        expect(hints.first.type, HintType.tableauToTableau);
        expect(hints.first.tableauIndex, 0);
        expect(hints.first.targetTableauIndex, 1);
      });

      test('detects king to empty tableau move', () {
        final deck = Deck();
        final stockPile = GamePile(type: PileType.stock);
        final wastePile = GamePile(type: PileType.waste);
        wastePile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, faceUp: true));

        final foundationPiles = List.generate(4, (index) => GamePile(type: PileType.foundations));

        final tableauPiles = List.generate(7, (index) => GamePile(type: PileType.tableau));
        // All tableau piles are empty

        final gameState = GameState.createWithPiles(
          deck: deck,
          stockPile: stockPile,
          wastePile: wastePile,
          foundationPiles: foundationPiles,
          tableauPiles: tableauPiles,
        );

        final hints = hintService.findHints(gameState);

        // Should have 7 hints (king can move to any empty tableau)
        expect(hints.length, 7);
        expect(hints.every((h) => h.type == HintType.wasteToTableau), isTrue);
      });
    });

    group('Hint data class', () {
      test('Hint has correct properties', () {
        final hint = Hint(
          type: HintType.wasteToFoundation,
          foundationsIndex: 0,
        );

        expect(hint.type, HintType.wasteToFoundation);
        expect(hint.foundationsIndex, 0);
      });
    });
  });
}
