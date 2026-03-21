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

  /// Callback when a card is tapped for auto-move.
  final Function(PlayingCard card)? onAutoMove;

  /// The index of this tableau pile (0-6).
  final int tableauIndex;

  /// Whether this pile is highlighted as part of a hint.
  final bool isHinted;

  const TableauPileWidget({
    super.key,
    required this.pile,
    required this.xOffset,
    this.onDrop,
    this.onAutoMove,
    this.tableauIndex = 0,
    this.isHinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardCount = pile.cards.length;
    final cardWidth = 80.0;
    final cardHeight = 120.0;
    final verticalOverlap = 20.0;

    // Calculate total size needed for the pile - cards stack vertically with small offset
    final totalWidth = cardWidth + 20.0;
    final totalHeight = cardCount > 0 ? cardHeight + (cardCount - 1) * verticalOverlap : cardHeight;

    return DragTarget<List<PlayingCard>>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (data.isEmpty) return false;
        return _isValidDrop(data.first);
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data.isNotEmpty && onDrop != null) {
          onDrop!(data.first, tableauIndex);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        return Semantics(
          label: 'Tableau pile ${tableauIndex + 1}${pile.isEmpty ? ', empty' : ', ${pile.cards.length} cards'}${isHinted ? ', hint available' : ''}',
          child: SizedBox(
            width: totalWidth,
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: pile.cards.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                return _buildCard(index, card, isDragOver);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(int index, PlayingCard card, bool isDragOver) {
    final isTopCard = index == pile.cards.length - 1;
    final isFaceUp = card.faceUp;

    // Calculate position - cards stack vertically with small horizontal offset for visual separation
    final cardX = index * 2.0;
    final cardY = index * 20.0;

    if (isTopCard && isFaceUp) {
      // Get all consecutive face-up cards from the top
      final stack = _getFaceUpStack();

      // Build the card widget with optional drag
      final isHighlighted = isHinted || isDragOver;
      final cardWidget = Container(
        decoration: BoxDecoration(
          border: isHighlighted ? Border.all(color: Colors.green, width: 2) : null,
          borderRadius: BorderRadius.circular(8),
          color: isHighlighted ? Colors.green.withValues(alpha: 0.2) : null,
        ),
        child: CardWidget(card: card),
      );

      // Only the top card is draggable, but it carries the whole stack
      return Positioned(
        left: cardX,
        top: cardY,
        child: Draggable<List<PlayingCard>>(
          data: stack,
          feedback: _buildStackPreview(stack, true),
          childWhenDragging: _buildFaceDownPlaceholder(),
          child: GestureDetector(
            onTap: onAutoMove != null ? () => onAutoMove!(card) : null,
            child: cardWidget,
          ),
        ),
      );
    }

    // Face-down cards or cards below face-up stack are not interactive
    return Positioned(
      left: cardX,
      top: cardY,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isHinted ? Colors.green.withValues(alpha: 0.2) : null,
        ),
        child: CardWidget(card: card),
      ),
    );
  }

  /// Returns all consecutive face-up cards from the top of the pile
  List<PlayingCard> _getFaceUpStack() {
    final stack = <PlayingCard>[];
    for (var i = pile.cards.length - 1; i >= 0; i--) {
      if (pile.cards[i].faceUp) {
        stack.insert(0, pile.cards[i]);
      } else {
        break;
      }
    }
    return stack;
  }

  /// Builds a face-down card placeholder shown while dragging
  Widget _buildFaceDownPlaceholder() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  /// Builds a visual preview of the card stack for drag feedback
  Widget _buildStackPreview(List<PlayingCard> stack, bool isFeedback) {
    if (stack.length == 1) {
      return CardWidget(
        card: stack.first,
        size: isFeedback ? const Size(85, 130) : const Size(80, 120),
      );
    }

    // Show fanned stack of cards with proper overlap
    final cardWidth = isFeedback ? 85.0 : 80.0;
    final cardHeight = isFeedback ? 130.0 : 120.0;
    final overlap = 15.0;
    final totalWidth = cardWidth + (stack.length - 1) * overlap;

    return SizedBox(
      width: totalWidth,
      height: cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: stack.asMap().entries.map((entry) {
          final i = entry.key;
          final card = entry.value;
          return Positioned(
            left: i * overlap,
            top: 0,
            child: CardWidget(
              card: card,
              size: Size(cardWidth, cardHeight),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isValidDrop(PlayingCard card) {
    if (!card.faceUp) return false;

    if (pile.isEmpty) {
      return card.rank == CardRank.king;
    }

    final topCard = pile.topCard;
    if (topCard == null) return false;

    final isOppositeColor = (card.suit.isRed && topCard.suit.isBlack) ||
        (card.suit.isBlack && topCard.suit.isRed);
    return isOppositeColor && card.rank.value == topCard.rank.value - 1;
  }
}

extension on CardSuit {
  bool get isRed => this == CardSuit.hearts || this == CardSuit.diamonds;
  bool get isBlack => this == CardSuit.spades || this == CardSuit.clubs;
}
