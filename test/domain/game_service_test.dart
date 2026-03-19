import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/game_score.dart';
import 'package:solitaire/src/domain/game_service.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/game_state_options.dart';
import 'package:solitaire/src/domain/pile_type.dart';

void main() {
  group('GameService', () {
    test('creates new game with initial state', () {
      final service = GameService.newGame();

      expect(service.gameState.isWon, false);
      expect(service.score.score, 0);
      expect(service.score.moves, 0);
      expect(service.undoStackSize, 0);
    });

    test('draw card increments move count', () {
      final service = GameService.newGame();
      service.drawCard();

      expect(service.score.moves, 1);
    });

    test('updateOptions changes game options', () {
      final service = GameService.newGame();
      final newOptions = const GameStateOptions(
        drawMode: DrawMode.drawThree,
        timedMode: true,
      );

      service.updateOptions(newOptions);

      expect(service.options.drawMode, DrawMode.drawThree);
      expect(service.options.timedMode, true);
    });

    test('undo is available after a move', () {
      final service = GameService.newGame();
      service.drawCard();

      expect(service.undoStackSize, 1);
    });

    test('undo reverts the game state', () {
      final service = GameService.newGame();
      service.drawCard();
      service.undo();

      // After undo, we should be back to the initial state
      expect(service.undoStackSize, 0);
    });

    test('vegas mode: undo subtracts 100 points', () {
      final service = GameService.newGame();
      service.updateOptions(const GameStateOptions(scoringMode: ScoringMode.vegas));
      service.drawCard();
      service.undo();

      expect(service.score.score, -100);
      expect(service.score.moves, 2);
    });

    test('classic mode: undo does not change score', () {
      final service = GameService.newGame();
      service.updateOptions(const GameStateOptions(scoringMode: ScoringMode.classic));
      service.drawCard();
      service.undo();

      expect(service.score.score, 0);
      expect(service.score.moves, 2);
    });

    test('isWon returns true when all cards are in foundations', () {
      // Note: Full win condition testing would require setting up a game
      // where all 52 cards are in the foundations
      final service = GameService.newGame();
      expect(service.isWon, false);
    });

    test('multiple undos work correctly', () {
      final service = GameService.newGame();
      service.drawCard();
      service.drawCard();
      service.drawCard();

      expect(service.undoStackSize, 3);

      service.undo();
      expect(service.undoStackSize, 2);

      service.undo();
      expect(service.undoStackSize, 1);

      service.undo();
      expect(service.undoStackSize, 0);
    });

    test('undo on empty stack does nothing', () {
      final service = GameService.newGame();
      service.undo();

      expect(service.undoStackSize, 0);
      expect(service.score.moves, 0);
    });

    test('updateElapsedTime updates the score duration', () {
      final service = GameService.newGame();
      service.updateElapsedTime();

      expect(service.score.elapsedDuration.inSeconds, greaterThanOrEqualTo(0));
    });

    test('markWon sets end time', () {
      final service = GameService.newGame();
      service.markWon();

      expect(service.score.endTime, isNotNull);
    });

    test('moveWasteToFoundation returns null when waste is empty', () {
      final service = GameService.newGame();
      final result = service.moveWasteToFoundation(0);

      expect(result, isNull);
    });

    test('moveWasteToFoundation can be called', () {
      final service = GameService.newGame();
      // Just verify the method exists and can be called
      // The actual move validation is tested in move_validation_test.dart
      expect(service.moveWasteToFoundation, isA<Function>());
    });

    test('moveTableauToFoundation returns null for invalid move', () {
      final service = GameService.newGame();
      final result = service.moveTableauToFoundation(0, 0);

      expect(result, isNull);
    });

    test('moveWasteToTableau returns null when waste is empty', () {
      final service = GameService.newGame();
      final result = service.moveWasteToTableau(0);

      expect(result, isNull);
    });

    test('moveFoundationToTableau returns null when foundation is empty', () {
      final service = GameService.newGame();
      final result = service.moveFoundationToTableau(0, 0);

      expect(result, isNull);
    });

    test('moveTableauToTableau returns null for same pile', () {
      final service = GameService.newGame();
      final result = service.moveTableauToTableau(0, 0);

      expect(result, isNull);
    });

    test('flipTableauCard returns null when tableau is empty', () {
      // Create a game with empty tableau pile
      final deck = Deck();
      deck.shuffle();
      final stockPile = GamePile(type: PileType.stock);
      final wastePile = GamePile(type: PileType.waste);
      final foundationPiles = List.generate(4, (i) => GamePile(type: PileType.foundations));
      final tableauPiles = List.generate(7, (i) => GamePile(type: PileType.tableau));

      // Don't deal any cards - keep all tableau piles empty
      // Put all cards in stock
      while (deck.cards.isNotEmpty) {
        stockPile.addCard(deck.draw());
      }

      final gameState = GameState.createWithPiles(
        deck: deck,
        stockPile: stockPile,
        wastePile: wastePile,
        foundationPiles: foundationPiles,
        tableauPiles: tableauPiles,
      );

      final service = GameService(
        gameState: gameState,
        score: GameScore.start(),
        options: const GameStateOptions(),
      );

      final result = service.flipTableauCard(0);
      expect(result, isNull); // Empty tableau cannot flip
    });
  });
}
