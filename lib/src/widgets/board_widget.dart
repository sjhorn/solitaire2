import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/hint_service.dart';
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

  /// Callback when a card is dropped on a foundation.
  final Function(PlayingCard card, int foundationIndex) onDropOnFoundation;

  /// Callback when a card is dropped on a tableau.
  final Function(PlayingCard card, int tableauIndex) onDropOnTableau;

  /// The current hint to highlight, if any.
  final Hint? hint;

  const BoardWidget({
    super.key,
    required this.gameState,
    required this.onStockTap,
    required this.onDropOnFoundation,
    required this.onDropOnTableau,
    this.hint,
  });

  bool _isHinted(int tableauIndex) {
    if (hint == null) return false;
    return hint!.tableauIndex == tableauIndex || hint!.targetTableauIndex == tableauIndex;
  }

  bool _isHintedFoundation(int foundationIndex) {
    if (hint == null) return false;
    return hint!.foundationsIndex == foundationIndex;
  }

  bool _isHintedWaste() {
    if (hint == null) return false;
    return hint!.type == HintType.wasteToFoundation ||
           hint!.type == HintType.wasteToTableau;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.constrainWidth();
        final height = constraints.constrainHeight();

        // If constraints are unbounded, use default dimensions
        final boardWidth = width.isFinite ? width : 800.0;
        final boardHeight = height.isFinite ? height : 600.0;

        return Stack(
          children: [
            // Top row: Stock, Waste, gap, Foundations
            _buildTopRow(boardWidth),
            // Bottom row: 7 Tableau piles
            _buildBottomRow(boardWidth, boardHeight),
          ],
        );
      },
    );
  }

  Widget _buildTopRow(double boardWidth) {
    final foundationPiles = gameState.foundationPiles;
    return Positioned(
      top: 20,
      left: (boardWidth - 600) / 2,
      child: Semantics(
        label: 'Top row: Stock, Waste, and Foundation piles',
        child: Row(
          children: [
            // Stock pile
            Semantics(
              label: 'Stock pile, tap to draw cards',
              button: true,
              child: StockPileWidget(pile: gameState.stockPile, onTap: onStockTap),
            ),
            // Waste pile
            Semantics(
              label: 'Waste pile${_isHintedWaste() ? ', hint available' : ''}',
              child: WastePileWidget(pile: gameState.wastePile, isHinted: _isHintedWaste()),
            ),
            // Gap
            const SizedBox(width: 60),
            // Foundation piles (up to 4)
            for (int i = 0; i < 4 && i < foundationPiles.length; i++)
              Semantics(
                label: 'Foundation pile ${i + 1}${_isHintedFoundation(i) ? ', hint available' : ''}',
                child: FoundationPileWidget(
                  pile: foundationPiles[i],
                  foundationIndex: i,
                  onDrop: onDropOnFoundation,
                  isHinted: _isHintedFoundation(i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow(double boardWidth, double boardHeight) {
    final tableauPiles = gameState.tableauPiles;
    return Positioned(
      top: 160,
      left: (boardWidth - 600) / 2,
      child: Row(
        children: List.generate(
          7,
          (index) => SizedBox(
            width: 80,
            child: index < tableauPiles.length
                ? TableauPileWidget(
                    pile: tableauPiles[index],
                    xOffset: 0,
                    tableauIndex: index,
                    onDrop: onDropOnTableau,
                    isHinted: _isHinted(index),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
