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
    return Positioned(
      left: xOffset,
      top: 0,
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
      child: CardWidget(card: card),
    );
  }
}
