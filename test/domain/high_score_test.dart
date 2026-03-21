import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/high_score.dart';

void main() {
  group('HighScore', () {
    final testScore = HighScore(
      score: 500,
      moves: 25,
      duration: const Duration(seconds: 120),
      playedAt: DateTime(2026, 3, 20, 10, 30),
      gameConfiguration: 'vegas-draw3',
    );

    test('creates HighScore with all fields', () {
      expect(testScore.score, 500);
      expect(testScore.moves, 25);
      expect(testScore.duration, const Duration(seconds: 120));
      expect(testScore.playedAt, DateTime(2026, 3, 20, 10, 30));
      expect(testScore.gameConfiguration, 'vegas-draw3');
    });

    test('fromJson creates HighScore correctly', () {
      final json = {
        'score': 500,
        'moves': 25,
        'durationSeconds': 120,
        'playedAt': '2026-03-20T10:30:00.000',
        'gameConfiguration': 'vegas-draw3',
      };

      final score = HighScore.fromJson(json);

      expect(score.score, 500);
      expect(score.moves, 25);
      expect(score.duration, const Duration(seconds: 120));
      expect(score.playedAt, DateTime(2026, 3, 20, 10, 30));
      expect(score.gameConfiguration, 'vegas-draw3');
    });

    test('toJson produces correct map', () {
      final json = testScore.toJson();

      expect(json['score'], 500);
      expect(json['moves'], 25);
      expect(json['durationSeconds'], 120);
      expect(json['playedAt'], '2026-03-20T10:30:00.000');
      expect(json['gameConfiguration'], 'vegas-draw3');
    });

    test('fromJson and toJson are symmetric', () {
      final json = testScore.toJson();
      final score = HighScore.fromJson(json);

      expect(score, testScore);
    });

    test('copyWith creates modified copy', () {
      final modified = testScore.copyWith(score: 1000);

      expect(modified.score, 1000);
      expect(modified.moves, 25);
      expect(modified.duration, const Duration(seconds: 120));
      expect(modified.playedAt, DateTime(2026, 3, 20, 10, 30));
      expect(modified.gameConfiguration, 'vegas-draw3');
    });

    test('equality works correctly', () {
      final same = HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20, 10, 30),
        gameConfiguration: 'vegas-draw3',
      );

      final different = HighScore(
        score: 600,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20, 10, 30),
        gameConfiguration: 'vegas-draw3',
      );

      expect(testScore, equals(same));
      expect(testScore, isNot(equals(different)));
    });

    test('hashCode is consistent', () {
      final hash1 = testScore.hashCode;
      final hash2 = testScore.hashCode;

      expect(hash1, equals(hash2));
    });
  });
}
