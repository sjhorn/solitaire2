import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A widget that displays a tableau pile with overlapping cards.
class TableauPileWidget extends StatelessWidget {
  /// The pile containing the cards to display.
  final GamePile pile;

  /// The horizontal position offset (for visual separation of piles).
  final double xOffset;

  const TableauPileWidget({
    super.key,
    required this.pile,
    required this.xOffset,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the width and height needed for all cards
    final cardCount = pile.cards.length;
    final cardWidth = 80.0; // Standard card width
    final cardHeight = 120.0; // Standard card height
    final overlap = 30.0;

    final totalWidth = cardCount > 0 ? cardWidth + (cardCount - 1) * overlap : cardWidth;
    final totalHeight = cardCount > 0 ? cardHeight + (cardCount - 1) * overlap : cardHeight;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        children: pile.cards
            .asMap()
            .entries
            .map((entry) => _buildCard(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  Widget _buildCard(int index, PlayingCard card) {
    return Positioned(
      left: index * 30, // Overlap cards horizontally
      top: index * 30, // Overlap cards vertically
      child: _buildDraggableCard(card, index),
    );
  }

  Widget _buildDraggableCard(PlayingCard card, int index) {
    final isTopCard = index == pile.cards.length - 1;
    final isFaceUp = card.faceUp;

    if (isTopCard && isFaceUp) {
      return Draggable<PlayingCard>(
        data: card,
        childWhenDragging: CardWidget(card: card),
        feedback: CardWidget(card: card),
        child: CardWidget(card: card),
      );
    }

    return CardWidget(card: card);
  }
}
