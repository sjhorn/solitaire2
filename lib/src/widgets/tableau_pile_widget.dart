import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A widget that displays a tableau pile with overlapping cards.
class TableauPileWidget extends StatelessWidget {
  /// The pile containing the cards to display.
  final GamePile pile;

  /// The horizontal position offset (for visual separation of piles).
  final double xOffset;

  /// Callback when a card is dropped on this tableau.
  final Function(PlayingCard card, int tableauIndex)? onDrop;

  /// The index of this tableau pile (0-6).
  final int tableauIndex;

  const TableauPileWidget({
    super.key,
    required this.pile,
    required this.xOffset,
    this.onDrop,
    this.tableauIndex = 0,
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

    return DragTarget<List<PlayingCard>>(
      onWillAccept: (data) {
        if (data == null || data.isEmpty) return false;
        final card = data.first;
        return _isValidDrop(card);
      },
      onAccept: (data) {
        if (data.isNotEmpty && onDrop != null) {
          onDrop!(data.first, tableauIndex);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        return SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            children: pile.cards
                .asMap()
                .entries
                .map((entry) => _buildCard(entry.key, entry.value, isDragOver))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildCard(int index, PlayingCard card, bool isDragOver) {
    return Positioned(
      left: index * 30, // Overlap cards horizontally
      top: index * 30, // Overlap cards vertically
      child: _buildDraggableCard(card, index, isDragOver),
    );
  }

  Widget _buildDraggableCard(PlayingCard card, int index, bool isDragOver) {
    final isTopCard = index == pile.cards.length - 1;
    final isFaceUp = card.faceUp;

    if (isTopCard && isFaceUp) {
      return Draggable<PlayingCard>(
        data: card,
        childWhenDragging: CardWidget(card: card),
        feedback: CardWidget(card: card),
        child: Container(
          decoration: BoxDecoration(
            border: isDragOver ? Border.all(color: Colors.green, width: 2) : null,
          ),
          child: CardWidget(card: card),
        ),
      );
    }

    return CardWidget(card: card);
  }

  bool _isValidDrop(PlayingCard card) {
    // Tableau accepts face-up cards only
    if (!card.faceUp) return false;

    if (pile.isEmpty) {
      // Only King can be placed on empty tableau
      return card.rank == CardRank.king;
    }

    final topCard = pile.topCard;
    if (topCard == null) return false;

    // Must be opposite color and descending rank
    final isOppositeColor = (card.suit.isRed && topCard.suit.isBlack) ||
        (card.suit.isBlack && topCard.suit.isRed);
    return isOppositeColor && card.rank.value == topCard.rank.value - 1;
  }
}

extension on CardSuit {
  bool get isRed => this == CardSuit.hearts || this == CardSuit.diamonds;
  bool get isBlack => this == CardSuit.spades || this == CardSuit.clubs;
}
