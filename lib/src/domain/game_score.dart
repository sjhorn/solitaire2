import 'package:solitaire/src/domain/game_state_options.dart';

/// Tracks the score, moves, and time for a game of solitaire.
class GameScore {
  final int score;
  final int moves;
  final Duration elapsedDuration;
  final DateTime? startTime;
  final DateTime? endTime;

  const GameScore({
    this.score = 0,
    this.moves = 0,
    this.elapsedDuration = Duration.zero,
    this.startTime,
    this.endTime,
  });

  /// Creates a new game score with the current time as start time.
  factory GameScore.start() {
    return GameScore(startTime: DateTime.now());
  }

  /// Calculates the score based on the move type and game options.
  ///
  /// Scoring rules (Vegas Standard):
  /// - +10 pts: waste → tableau
  /// - +10 pts: tableau → foundation
  /// - +5 pts: turning over a tableau card
  /// - –2 pts per 10 seconds: time penalty (timed mode)
  /// - –100 pts: undo move (Vegas mode)
  GameScore addMove({
    required GameStateOptions options,
    required MoveType moveType,
    bool isUndo = false,
  }) {
    // Handle undo moves
    if (isUndo) {
      if (options.scoringMode == ScoringMode.vegas) {
        return GameScore(
          score: score - 100,
          moves: moves + 1,
          elapsedDuration: elapsedDuration,
          startTime: startTime,
        );
      }
      // Classic mode: undo doesn't change score
      return GameScore(
        score: score,
        moves: moves + 1,
        elapsedDuration: elapsedDuration,
        startTime: startTime,
      );
    }

    int points = 0;
    switch (moveType) {
      case MoveType.wasteToTableau:
        points = 10;
        break;
      case MoveType.wasteToFoundation:
        points = 10;
        break;
      case MoveType.tableauToFoundation:
        points = 10;
        break;
      case MoveType.tableauToTableau:
        points = 0;
        break;
      case MoveType.foundationToTableau:
        points = 0;
        break;
      case MoveType.stockToWaste:
        points = 0;
        break;
      case MoveType.flipTableau:
        points = 5;
        break;
      case MoveType.draw:
        points = 0;
        break;
    }

    // Apply time penalty for timed mode
    if (options.timedMode) {
      final seconds = elapsedDuration.inSeconds;
      final timePenalty = (seconds / 10).floor() * 2;
      points -= timePenalty;
    }

    return GameScore(
      score: score + points,
      moves: moves + 1,
      elapsedDuration: elapsedDuration,
      startTime: startTime,
    );
  }

  /// Updates the elapsed duration.
  GameScore updateElapsedTime() {
    if (startTime == null) return this;
    final now = DateTime.now();
    final newElapsed = now.difference(startTime!);
    return GameScore(
      score: score,
      moves: moves,
      elapsedDuration: newElapsed,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Marks the game as won and stops the timer.
  GameScore markWon() {
    if (endTime != null) return this;
    final now = DateTime.now();
    final newElapsed = startTime != null ? now.difference(startTime!) : elapsedDuration;
    return GameScore(
      score: score,
      moves: moves,
      elapsedDuration: newElapsed,
      startTime: startTime,
      endTime: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameScore &&
        other.score == score &&
        other.moves == moves &&
        other.elapsedDuration == elapsedDuration &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode =>
      score.hashCode ^
      moves.hashCode ^
      elapsedDuration.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;
}

/// Types of moves in solitaire for scoring purposes.
enum MoveType {
  wasteToTableau,
  wasteToFoundation,
  tableauToFoundation,
  tableauToTableau,
  foundationToTableau,
  stockToWaste,
  flipTableau,
  draw,
}
