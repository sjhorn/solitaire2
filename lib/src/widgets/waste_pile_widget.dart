import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A widget that displays the waste pile.
///
/// The waste pile contains cards that have been drawn from the stock.
class WastePileWidget extends StatelessWidget {
  /// The waste pile containing cards.
  final GamePile pile;

  /// Callback when the waste pile is tapped.
  final VoidCallback? onTap;

  /// Callback when a card is dropped on a target.
  final Function(PlayingCard card)? onDrop;

  /// Whether this pile is highlighted as part of a hint.
  final bool isHinted;

  const WastePileWidget({
    super.key,
    required this.pile,
    this.onTap,
    this.onDrop,
    this.isHinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = pile.isEmpty;
    final cardCount = pile.cards.length;

    if (isEmpty) {
      return Semantics(
        label: 'Waste pile, empty, tap to draw cards',
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 120,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: isHinted ? Colors.green : Colors.grey, width: isHinted ? 3 : 2),
              borderRadius: BorderRadius.circular(8),
              color: isHinted ? Colors.green.withValues(alpha: 0.2) : null,
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      );
    }

    final topCard = pile.topCardThrow;

    return DragTarget<List<PlayingCard>>(
      onWillAcceptWithDetails: (details) => false,
      builder: (context, candidateData, rejectedData) {
        return Semantics(
          label: 'Waste pile, $cardCount cards, tap to draw',
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 80,
              height: 120,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: isHinted ? Colors.green : Colors.grey, width: isHinted ? 3 : 2),
                borderRadius: BorderRadius.circular(8),
                color: isHinted ? Colors.green.withValues(alpha: 0.2) : null,
              ),
              child: Draggable<List<PlayingCard>>(
                data: [topCard],
                feedback: CardWidget(card: topCard, size: const Size(85, 130)),
                childWhenDragging: Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                child: CardWidget(card: topCard),
              ),
            ),
          ),
        );
      },
    );
  }
}
