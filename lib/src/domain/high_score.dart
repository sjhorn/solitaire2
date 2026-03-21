/// Represents a high score entry for a completed game.
class HighScore {
  final int score;
  final int moves;
  final Duration duration;
  final DateTime playedAt;
  final String gameConfiguration;

  const HighScore({
    required this.score,
    required this.moves,
    required this.duration,
    required this.playedAt,
    required this.gameConfiguration,
  });

  /// Creates a HighScore from a JSON map.
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      score: json['score'] as int,
      moves: json['moves'] as int,
      duration: Duration(seconds: json['durationSeconds'] as int),
      playedAt: DateTime.parse(json['playedAt'] as String),
      gameConfiguration: json['gameConfiguration'] as String,
    );
  }

  /// Converts this HighScore to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'moves': moves,
      'durationSeconds': duration.inSeconds,
      'playedAt': playedAt.toIso8601String(),
      'gameConfiguration': gameConfiguration,
    };
  }

  /// Creates a copy with the given fields replaced.
  HighScore copyWith({
    int? score,
    int? moves,
    Duration? duration,
    DateTime? playedAt,
    String? gameConfiguration,
  }) {
    return HighScore(
      score: score ?? this.score,
      moves: moves ?? this.moves,
      duration: duration ?? this.duration,
      playedAt: playedAt ?? this.playedAt,
      gameConfiguration: gameConfiguration ?? this.gameConfiguration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HighScore &&
        other.score == score &&
        other.moves == moves &&
        other.duration == duration &&
        other.playedAt == playedAt &&
        other.gameConfiguration == gameConfiguration;
  }

  @override
  int get hashCode =>
      score.hashCode ^
      moves.hashCode ^
      duration.hashCode ^
      playedAt.hashCode ^
      gameConfiguration.hashCode;
}
