import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A widget that displays the stock pile.
///
/// The stock is the draw pile from which players draw cards.
class StockPileWidget extends StatelessWidget {
  /// The stock pile containing cards.
  final GamePile pile;

  /// Callback when the stock is tapped (to draw a card).
  final VoidCallback onTap;

  const StockPileWidget({super.key, required this.pile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardCount = pile.cards.length;
    final isEmpty = pile.isEmpty;

    return Semantics(
      label: 'Stock pile, ${isEmpty ? 'empty' : '$cardCount cards remaining'}',
      button: !isEmpty,
      child: GestureDetector(
        onTap: isEmpty ? null : onTap,
        child: Container(
          width: 80,
          height: 120,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isEmpty
              ? null
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = pile.cards.length - 1; i >= 0 && i > pile.cards.length - 6; i--)
                      Positioned(
                        left: (pile.cards.length - 1 - i) * 1.5,
                        top: (pile.cards.length - 1 - i) * 1.5,
                        child: CardWidget(
                          card: pile.cards[i],
                          size: const Size(80, 120),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
