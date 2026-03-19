import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/game_score.dart';
import 'package:solitaire/src/domain/game_state_options.dart';

void main() {
  group('GameScore', () {
    test('starts with zero score and moves', () {
      final score = GameScore.start();
      expect(score.score, 0);
      expect(score.moves, 0);
      expect(score.startTime, isNotNull);
    });

    test('classic mode: waste to foundation adds 10 points', () {
      final options = GameStateOptions(scoringMode: ScoringMode.classic);
      var score = GameScore.start();
      score = score.addMove(options: options, moveType: MoveType.wasteToFoundation);

      expect(score.score, 10);
      expect(score.moves, 1);
    });

    test('classic mode: tableau to foundation adds 10 points', () {
      final options = GameStateOptions(scoringMode: ScoringMode.classic);
      var score = GameScore.start();
      score = score.addMove(options: options, moveType: MoveType.tableauToFoundation);

      expect(score.score, 10);
      expect(score.moves, 1);
    });

    test('classic mode: flipping tableau card adds 5 points', () {
      final options = GameStateOptions(scoringMode: ScoringMode.classic);
      var score = GameScore.start();
      score = score.addMove(options: options, moveType: MoveType.flipTableau);

      expect(score.score, 5);
      expect(score.moves, 1);
    });

    test('vegas mode: waste to tableau adds 10 points', () {
      final options = GameStateOptions(scoringMode: ScoringMode.vegas);
      var score = GameScore.start();
      score = score.addMove(options: options, moveType: MoveType.wasteToTableau);

      expect(score.score, 10);
      expect(score.moves, 1);
    });

    test('vegas mode: undo move subtracts 100 points', () {
      final options = GameStateOptions(scoringMode: ScoringMode.vegas);
      var score = GameScore.start();
      score = score.addMove(options: options, moveType: MoveType.wasteToFoundation);
      score = score.addMove(options: options, moveType: MoveType.wasteToFoundation, isUndo: true);

      expect(score.score, -90); // 10 - 100
      expect(score.moves, 2);
    });

    test('classic mode: undo move does not penalize', () {
      final options = GameStateOptions(scoringMode: ScoringMode.classic);
      var score = GameScore.start();
      score = score.addMove(options: options, moveType: MoveType.wasteToFoundation);
      score = score.addMove(options: options, moveType: MoveType.wasteToFoundation, isUndo: true);

      expect(score.score, 10); // No penalty in classic mode
      expect(score.moves, 2);
    });

    test('timed mode: applies time penalty', () {
      final options = GameStateOptions(timedMode: true);
      var score = GameScore(
        score: 100,
        moves: 10,
        elapsedDuration: const Duration(seconds: 30),
        startTime: DateTime.now().subtract(const Duration(seconds: 30)),
      );

      score = score.addMove(options: options, moveType: MoveType.tableauToTableau);

      // 30 seconds = 3 * 10 second intervals = 6 points penalty
      expect(score.score, 94); // 100 - 6
      expect(score.moves, 11);
    });

    test('timed mode: no penalty for 0-9 seconds', () {
      final options = GameStateOptions(timedMode: true);
      var score = GameScore(
        score: 100,
        moves: 10,
        elapsedDuration: const Duration(seconds: 5),
        startTime: DateTime.now().subtract(const Duration(seconds: 5)),
      );

      score = score.addMove(options: options, moveType: MoveType.tableauToTableau);

      expect(score.score, 100); // No penalty yet
      expect(score.moves, 11);
    });

    test('timed mode: penalty increases with time', () {
      final options = GameStateOptions(timedMode: true);
      var score = GameScore(
        score: 100,
        moves: 10,
        elapsedDuration: const Duration(seconds: 60),
        startTime: DateTime.now().subtract(const Duration(seconds: 60)),
      );

      score = score.addMove(options: options, moveType: MoveType.tableauToTableau);

      // 60 seconds = 6 * 10 second intervals = 12 points penalty
      expect(score.score, 88); // 100 - 12
      expect(score.moves, 11);
    });

    test('updateElapsedTime updates the duration', () {
      final startTime = DateTime.now().subtract(const Duration(seconds: 30));
      var score = GameScore(startTime: startTime);

      score = score.updateElapsedTime();

      expect(score.elapsedDuration.inSeconds, greaterThanOrEqualTo(30));
    });

    test('markWon stops the timer', () {
      final startTime = DateTime.now().subtract(const Duration(seconds: 60));
      var score = GameScore(startTime: startTime);

      // Wait a bit
      score = score.updateElapsedTime();
      final beforeEnd = score.elapsedDuration;

      score = score.markWon();

      expect(score.endTime, isNotNull);
      expect(score.elapsedDuration, greaterThanOrEqualTo(beforeEnd));
    });

    test('markWon multiple times returns same score', () {
      final startTime = DateTime.now().subtract(const Duration(seconds: 60));
      var score = GameScore(startTime: startTime);
      score = score.markWon();
      final firstMarked = score;

      score = score.markWon();

      expect(score, equals(firstMarked));
    });

    test('GameScore equality', () {
      final score1 = GameScore(score: 100, moves: 20, elapsedDuration: const Duration(seconds: 60));
      final score2 = GameScore(score: 100, moves: 20, elapsedDuration: const Duration(seconds: 60));
      final score3 = GameScore(score: 50, moves: 10, elapsedDuration: const Duration(seconds: 30));

      expect(score1, equals(score2));
      expect(score1, isNot(equals(score3)));
    });
  });

  group('GameStateOptions', () {
    test('default values', () {
      const options = GameStateOptions();
      expect(options.drawMode, DrawMode.drawOne);
      expect(options.scoringMode, ScoringMode.classic);
      expect(options.timedMode, false);
      expect(options.soundEnabled, true);
    });

    test('copyWith updates specified fields', () {
      const options = GameStateOptions();
      final newOptions = options.copyWith(
        drawMode: DrawMode.drawThree,
        timedMode: true,
      );

      expect(newOptions.drawMode, DrawMode.drawThree);
      expect(newOptions.scoringMode, ScoringMode.classic); // unchanged
      expect(newOptions.timedMode, true);
      expect(newOptions.soundEnabled, true); // unchanged
    });

    test('equality', () {
      const options1 = GameStateOptions(drawMode: DrawMode.drawThree);
      const options2 = GameStateOptions(drawMode: DrawMode.drawThree);
      const options3 = GameStateOptions();

      expect(options1, equals(options2));
      expect(options1, isNot(equals(options3)));
    });

    test('copyWith updates all fields', () {
      const options = GameStateOptions();
      final newOptions = options.copyWith(
        drawMode: DrawMode.drawThree,
        scoringMode: ScoringMode.vegas,
        timedMode: true,
        soundEnabled: false,
      );

      expect(newOptions.drawMode, DrawMode.drawThree);
      expect(newOptions.scoringMode, ScoringMode.vegas);
      expect(newOptions.timedMode, true);
      expect(newOptions.soundEnabled, false);
    });

    test('copyWith with no arguments returns equal instance', () {
      const options = GameStateOptions(drawMode: DrawMode.drawThree, timedMode: true);
      final copy = options.copyWith();

      expect(copy, equals(options));
    });

    test('hashCode is consistent', () {
      const options1 = GameStateOptions(drawMode: DrawMode.drawThree);
      const options2 = GameStateOptions(drawMode: DrawMode.drawThree);

      expect(options1.hashCode, equals(options2.hashCode));
    });

    test('hashCode differs for different options', () {
      const options1 = GameStateOptions();
      const options2 = GameStateOptions(timedMode: true);

      expect(options1.hashCode, isNot(equals(options2.hashCode)));
    });
  });
}
