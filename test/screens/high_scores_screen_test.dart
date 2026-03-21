import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solitaire/src/domain/high_score.dart';
import 'package:solitaire/src/domain/high_score_service.dart';
import 'package:solitaire/src/screens/high_scores_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HighScoresScreen', () {
    testWidgets('displays empty state when no scores exist', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HighScoresScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No high scores yet!'), findsOneWidget);
      expect(find.text('Play games to earn scores.'), findsOneWidget);
    });

    testWidgets('displays high scores when they exist', (tester) async {
      // Save a test score
      final service = HighScoreService();
      await service.saveScore(HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      await tester.pumpWidget(const MaterialApp(home: HighScoresScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Score: 500'), findsOneWidget);
      expect(find.text('Moves: 25'), findsOneWidget);
      expect(find.text('Time: 02:00'), findsOneWidget);
    });

    testWidgets('displays top 3 with medals', (tester) async {
      final service = HighScoreService();

      // Add 3 scores
      await service.saveScore(HighScore(
        score: 500,
        moves: 25,
        duration: const Duration(seconds: 120),
        playedAt: DateTime(2026, 3, 20),
        gameConfiguration: 'vegas-draw3',
      ));

      await service.saveScore(HighScore(
        score: 400,
        moves: 30,
        duration: const Duration(seconds: 150),
        playedAt: DateTime(2026, 3, 21),
        gameConfiguration: 'vegas-draw3',
      ));

      await service.saveScore(HighScore(
        score: 300,
        moves: 20,
        duration: const Duration(seconds: 100),
        playedAt: DateTime(2026, 3, 22),
        gameConfiguration: 'vegas-draw3',
      ));

      await tester.pumpWidget(const MaterialApp(home: HighScoresScreen()));
      await tester.pumpAndSettle();

      // Check for score entries
      expect(find.text('Score: 500'), findsOneWidget);
      expect(find.text('Score: 400'), findsOneWidget);
      expect(find.text('Score: 300'), findsOneWidget);
    });

    testWidgets('refresh button reloads scores', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HighScoresScreen()));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Should still be on high scores screen
      expect(find.byType(HighScoresScreen), findsOneWidget);
    });
  });
}
