import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solitaire/src/domain/high_score.dart';
import 'package:solitaire/src/domain/high_score_service.dart';

void main() {
  late HighScoreService highScoreService;

  setUp(() {
    highScoreService = HighScoreService();
    SharedPreferences.setMockInitialValues({});
  });

  group('HighScoreService', () {
    test('saves a high score successfully', () async {
      final score = HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      );

      final result = await highScoreService.saveScore(score);

      expect(result, isTrue);
    });

    test('retrieves saved high scores for a configuration', () async {
      final score = HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      );

      await highScoreService.saveScore(score);
      final scores = await highScoreService.getHighScores('vegas-draw3');

      expect(scores, hasLength(1));
      expect(scores.first.score, 500);
      expect(scores.first.gameConfiguration, 'vegas-draw3');
    });

    test('sorts scores by score descending', () async {
      await highScoreService.saveScore(HighScore(
        score: 300,
        moves: 30,
        duration: const Duration(seconds: 180),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      await highScoreService.saveScore(HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 21),
        gameConfiguration: 'vegas-draw3',
      ));

      final scores = await highScoreService.getHighScores('vegas-draw3');

      expect(scores[0].score, 500);
      expect(scores[1].score, 300);
    });

    test('sorts by duration ascending when scores are equal', () async {
      await highScoreService.saveScore(HighScore(
        score: 500,
        moves: 30,
        duration: const Duration(seconds: 180),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      await highScoreService.saveScore(HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 21),
        gameConfiguration: 'vegas-draw3',
      ));

      final scores = await highScoreService.getHighScores('vegas-draw3');

      expect(scores[0].duration, const Duration(seconds: 120));
      expect(scores[1].duration, const Duration(seconds: 180));
    });

    test('keeps only top 10 scores per configuration', () async {
      // Add 15 scores
      for (int i = 1; i <= 15; i++) {
        await highScoreService.saveScore(HighScore(
          score: i * 100,
          moves: 20,
          duration: const Duration(seconds: 100),
          playedAt: DateTime(2026, 3, i),
          gameConfiguration: 'vegas-draw3',
        ));
      }

      final scores = await highScoreService.getHighScores('vegas-draw3');

      expect(scores, hasLength(10));
      expect(scores.first.score, 1500);
      expect(scores.last.score, 600);
    });

    test('gets all high scores across configurations', () async {
      await highScoreService.saveScore(HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      await highScoreService.saveScore(HighScore(
        score: 400,
        moves: 30,
        duration: const Duration(seconds: 150),
        playedAt: DateTime(2026, 3, 21),
        gameConfiguration: 'classic-draw1',
      ));

      final allScores = await highScoreService.getAllHighScores();

      expect(allScores, hasLength(2));
      expect(allScores['vegas-draw3'], hasLength(1));
      expect(allScores['classic-draw1'], hasLength(1));
    });

    test('returns empty list for non-existent configuration', () async {
      final scores = await highScoreService.getHighScores('non-existent');

      expect(scores, isEmpty);
    });

    test('returns null for best score when no scores exist', () async {
      final best = await highScoreService.getBestScore('non-existent');

      expect(best, isNull);
    });

    test('returns best score when scores exist', () async {
      await highScoreService.saveScore(HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      await highScoreService.saveScore(HighScore(
        score: 300,
        moves: 30,
        duration: const Duration(seconds: 180),
        playedAt: DateTime(2026, 3, 21),
        gameConfiguration: 'vegas-draw3',
      ));

      final best = await highScoreService.getBestScore('vegas-draw3');

      expect(best?.score, 500);
    });

    test('wouldQualify returns true when leaderboard not full', () async {
      // Only add 3 scores (less than max of 10)
      for (int i = 1; i <= 3; i++) {
        await highScoreService.saveScore(HighScore(
          score: i * 100,
          moves: 20,
          duration: const Duration(seconds: 100),
          playedAt: DateTime(2026, 3, i),
          gameConfiguration: 'vegas-draw3',
        ));
      }

      final qualifies = await highScoreService.wouldQualify(HighScore(
        score: 50,
        moves: 20,
        duration: const Duration(seconds: 100),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      expect(qualifies, isTrue);
    });

    test('wouldQualify returns true when score is higher than lowest', () async {
      // Fill leaderboard with 10 scores
      for (int i = 1; i <= 10; i++) {
        await highScoreService.saveScore(HighScore(
          score: i * 100,
          moves: 20,
          duration: const Duration(seconds: 100),
          playedAt: DateTime(2026, 3, i),
          gameConfiguration: 'vegas-draw3',
        ));
      }

      // Score of 950 would qualify (beats lowest of 1000)
      final qualifies = await highScoreService.wouldQualify(HighScore(
        score: 950,
        moves: 20,
        duration: const Duration(seconds: 100),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      expect(qualifies, isTrue);
    });

    test('wouldQualify returns false when score is lower than lowest', () async {
      // Fill leaderboard with 10 scores
      for (int i = 1; i <= 10; i++) {
        await highScoreService.saveScore(HighScore(
          score: i * 100,
          moves: 20,
          duration: const Duration(seconds: 100),
          playedAt: DateTime(2026, 3, i),
          gameConfiguration: 'vegas-draw3',
        ));
      }

      // Score of 50 would not qualify
      final qualifies = await highScoreService.wouldQualify(HighScore(
        score: 50,
        moves: 20,
        duration: const Duration(seconds: 100),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      expect(qualifies, isFalse);
    });

    test('wouldQualify returns true when same score but faster time', () async {
      // Fill leaderboard with 10 scores
      for (int i = 1; i <= 10; i++) {
        await highScoreService.saveScore(HighScore(
          score: 1000,
          moves: 20,
          duration: Duration(seconds: 100 + i * 10),
          playedAt: DateTime(2026, 3, i),
          gameConfiguration: 'vegas-draw3',
        ));
      }

      // Same score but faster time should qualify
      final qualifies = await highScoreService.wouldQualify(HighScore(
        score: 1000,
        moves: 20,
        duration: const Duration(seconds: 50),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      expect(qualifies, isTrue);
    });

    test('clearAllScores removes all scores', () async {
      await highScoreService.saveScore(HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      await highScoreService.clearAllScores();

      final scores = await highScoreService.getAllHighScores();
      expect(scores, isEmpty);
    });
  });
}
