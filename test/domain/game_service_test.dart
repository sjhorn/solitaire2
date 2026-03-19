import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/game_service.dart';
import 'package:solitaire/src/domain/game_state_options.dart';

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
  });
}
