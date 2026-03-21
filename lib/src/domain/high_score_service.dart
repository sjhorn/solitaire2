import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solitaire/src/domain/high_score.dart';

/// Service for managing high scores persistence.
class HighScoreService {
  static const String _highScoresKey = 'high_scores';
  static const int _maxScoresPerConfiguration = 10;

  /// Saves a high score.
  ///
  /// Returns true if the score was saved (i.e., it qualified for the leaderboard).
  Future<bool> saveScore(HighScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = _getScoresFromPrefs(prefs);

    final configurationScores = scores[score.gameConfiguration] ?? [];
    configurationScores.add(score);

    // Sort by score descending, then by duration ascending (faster is better)
    configurationScores.sort((a, b) {
      if (a.score != b.score) {
        return b.score - a.score; // Higher score first
      }
      return a.duration.inSeconds.compareTo(b.duration.inSeconds); // Shorter time first
    });

    // Keep only top scores
    if (configurationScores.length > _maxScoresPerConfiguration) {
      configurationScores.removeRange(
        _maxScoresPerConfiguration,
        configurationScores.length,
      );
    }

    scores[score.gameConfiguration] = configurationScores;
    await prefs.setString(_highScoresKey, jsonEncode(scores));

    return true;
  }

  /// Gets all high scores for a specific game configuration.
  Future<List<HighScore>> getHighScores(String configuration) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = _getScoresFromPrefs(prefs);
    return scores[configuration] ?? [];
  }

  /// Gets all high scores for all configurations.
  Future<Map<String, List<HighScore>>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    return _getScoresFromPrefs(prefs);
  }

  /// Clears all high scores.
  Future<void> clearAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_highScoresKey);
  }

  /// Gets the best score for a configuration.
  Future<HighScore?> getBestScore(String configuration) async {
    final scores = await getHighScores(configuration);
    return scores.isNotEmpty ? scores.first : null;
  }

  /// Checks if a score would qualify for the leaderboard.
  Future<bool> wouldQualify(HighScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = _getScoresFromPrefs(prefs);

    final configurationScores = scores[score.gameConfiguration] ?? [];

    // If we have fewer than max scores, it qualifies
    if (configurationScores.length < _maxScoresPerConfiguration) {
      return true;
    }

    // Check if it's better than the lowest qualifying score
    final lastScore = configurationScores.last;
    if (score.score > lastScore.score) {
      return true;
    }

    // Same score but faster time
    if (score.score == lastScore.score &&
        score.duration.inSeconds < lastScore.duration.inSeconds) {
      return true;
    }

    return false;
  }

  /// Deserializes scores from SharedPreferences.
  Map<String, List<HighScore>> _getScoresFromPrefs(SharedPreferences prefs) {
    final scoresJson = prefs.getString(_highScoresKey);
    if (scoresJson == null) {
      return {};
    }

    try {
      final Map<String, dynamic> scoresMap = jsonDecode(scoresJson);
      return scoresMap.map((key, value) {
        final List<dynamic> scoreList = value as List<dynamic>;
        return MapEntry(
          key,
          scoreList.map((s) => HighScore.fromJson(s as Map<String, dynamic>)).toList(),
        );
      });
    } catch (e) {
      return {};
    }
  }
}
