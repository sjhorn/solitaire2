import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A widget that displays a foundation pile.
///
/// Foundation piles can hold one card at a time (Ace through King of each suit).
class FoundationPileWidget extends StatelessWidget {
  /// The pile containing the cards to display.
  final GamePile pile;

  /// Callback when a card is dropped on this foundation.
  final Function(PlayingCard card, int foundationIndex)? onDrop;

  /// The index of this foundation pile (0-3).
  final int foundationIndex;

  /// Whether this pile is highlighted as part of a hint.
  final bool isHinted;

  const FoundationPileWidget({
    super.key,
    required this.pile,
    this.onDrop,
    this.foundationIndex = 0,
    this.isHinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<List<PlayingCard>>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (data.isEmpty) return false;
        final card = data.first;
        return _isValidDrop(card);
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data.isNotEmpty && onDrop != null) {
          onDrop!(data.first, foundationIndex);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        final borderColor = isHinted ? Colors.green : (isDragOver ? Colors.green : Colors.grey);
        final borderWidth = isHinted ? 3.0 : (isDragOver ? 3.0 : 2.0);
        final bgColor = isHinted ? Colors.green.withValues(alpha: 0.2) : (isDragOver ? Colors.green.withValues(alpha: 0.2) : null);
        return Container(
          width: 80,
          height: 120,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(8),
            color: bgColor,
          ),
          child: Center(
            child: pile.isEmpty
                ? Text(
                    'A',
                    style: TextStyle(
                      fontSize: 48,
                      color: isHinted ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : CardWidget(card: pile.topCardThrow),
          ),
        );
      },
    );
  }

  bool _isValidDrop(PlayingCard card) {
    // Foundation accepts only face-up cards
    if (!card.faceUp) return false;

    if (pile.isEmpty) {
      // Only Ace can be placed on empty foundation
      return card.rank.value == 1;
    }

    final topCard = pile.topCard;
    if (topCard == null) return false;

    // Must be same suit and next rank
    return card.suit == topCard.suit && card.rank.value == topCard.rank.value + 1;
  }
}
