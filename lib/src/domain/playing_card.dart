import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';

/// A playing card with a suit and rank.
///
/// Cards can be face-up or face-down. Face-down cards are considered equal
/// regardless of their suit and rank, as the suit and rank are hidden.
class PlayingCard {
  /// Creates a playing card with the given suit and rank.
  ///
  /// [suit] is the suit of the card (Spades, Hearts, Diamonds, or Clubs).
  /// [rank] is the rank of the card (Ace through King).
  /// [faceUp] determines if the card is face-up. Defaults to true.
  /// [isSelected] determines if the card is selected. Defaults to false.
  const PlayingCard({
    required this.suit,
    required this.rank,
    this.faceUp = true,
    this.isSelected = false,
  });

  /// The suit of this card.
  final CardSuit suit;

  /// The rank of this card.
  final CardRank rank;

  /// Whether this card is face-up.
  final bool faceUp;

  /// Whether this card is selected.
  final bool isSelected;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! PlayingCard) return false;

    // Face-down cards are equal regardless of suit and rank
    if (!faceUp && !other.faceUp) return true;

    return other.rank == rank &&
        other.suit == suit &&
        other.faceUp == faceUp &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    if (!faceUp) return faceUp.hashCode ^ isSelected.hashCode;
    return suit.hashCode ^
        rank.hashCode ^
        faceUp.hashCode ^
        isSelected.hashCode;
  }

  @override
  String toString() {
    if (!faceUp) return 'Face-down card';
    return '${rank.toStringValue} of ${suit.symbol}';
  }

  /// Returns a new PlayingCard with the specified fields.
  PlayingCard copyWith({
    CardSuit? suit,
    CardRank? rank,
    bool? faceUp,
    bool? isSelected,
  }) {
    return PlayingCard(
      suit: suit ?? this.suit,
      rank: rank ?? this.rank,
      faceUp: faceUp ?? this.faceUp,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
