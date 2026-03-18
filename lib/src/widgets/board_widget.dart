import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/widgets/foundation_pile_widget.dart';
import 'package:solitaire/src/widgets/stock_pile_widget.dart';
import 'package:solitaire/src/widgets/tableau_pile_widget.dart';
import 'package:solitaire/src/widgets/waste_pile_widget.dart';

/// A widget that displays the complete solitaire board layout.
///
/// The layout consists of:
/// - Top row: Stock, Waste, gap, Foundation piles (4)
/// - Bottom row: 7 Tableau piles
class BoardWidget extends StatelessWidget {
  /// The current game state.
  final GameState gameState;

  /// Callback when the stock pile is tapped.
  final VoidCallback onStockTap;

  const BoardWidget({
    super.key,
    required this.gameState,
    required this.onStockTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Top row: Stock, Waste, gap, Foundations
            _buildTopRow(constraints.maxWidth),
            // Bottom row: 7 Tableau piles
            _buildBottomRow(constraints.maxWidth, constraints.maxHeight),
          ],
        );
      },
    );
  }

  Widget _buildTopRow(double boardWidth) {
    return Positioned(
      top: 20,
      left: (boardWidth - 600) / 2,
      child: Row(
        children: [
          // Stock pile
          StockPileWidget(pile: gameState.stockPile, onTap: onStockTap),
          // Waste pile
          WastePileWidget(pile: gameState.wastePile),
          // Gap
          const SizedBox(width: 60),
          // Foundation piles
          ...gameState.foundationPiles.asMap().entries.map(
            (entry) => FoundationPileWidget(pile: entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(double boardWidth, double boardHeight) {
    return Positioned(
      top: 160,
      left: (boardWidth - 600) / 2,
      child: Stack(
        children: List.generate(
          7,
          (index) => TableauPileWidget(
            pile: gameState.tableauPiles[index],
            xOffset: index * 40,
          ),
        ),
      ),
    );
  }
}
