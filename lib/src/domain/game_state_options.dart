/// Game options for scoring, draw mode, and other settings.
enum DrawMode {
  drawOne,
  drawThree,
}

enum ScoringMode {
  classic,
  vegas,
}

enum CardBackDesign {
  classic,
  blue,
  red,
  green,
}

class GameStateOptions {
  final DrawMode drawMode;
  final ScoringMode scoringMode;
  final bool timedMode;
  final bool soundEnabled;
  final CardBackDesign cardBackDesign;

  const GameStateOptions({
    this.drawMode = DrawMode.drawOne,
    this.scoringMode = ScoringMode.classic,
    this.timedMode = false,
    this.soundEnabled = true,
    this.cardBackDesign = CardBackDesign.classic,
  });

  /// Creates a copy with the given fields replaced.
  GameStateOptions copyWith({
    DrawMode? drawMode,
    ScoringMode? scoringMode,
    bool? timedMode,
    bool? soundEnabled,
    CardBackDesign? cardBackDesign,
  }) {
    return GameStateOptions(
      drawMode: drawMode ?? this.drawMode,
      scoringMode: scoringMode ?? this.scoringMode,
      timedMode: timedMode ?? this.timedMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      cardBackDesign: cardBackDesign ?? this.cardBackDesign,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStateOptions &&
        other.drawMode == drawMode &&
        other.scoringMode == scoringMode &&
        other.timedMode == timedMode &&
        other.soundEnabled == soundEnabled &&
        other.cardBackDesign == cardBackDesign;
  }

  @override
  int get hashCode =>
      drawMode.hashCode ^
      scoringMode.hashCode ^
      timedMode.hashCode ^
      soundEnabled.hashCode ^
      cardBackDesign.hashCode;
}
