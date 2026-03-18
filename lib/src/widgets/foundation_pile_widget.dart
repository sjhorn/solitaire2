import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A widget that displays a foundation pile.
///
/// Foundation piles can hold one card at a time (Ace through King of each suit).
class FoundationPileWidget extends StatelessWidget {
  /// The pile containing the cards to display.
  final GamePile pile;

  const FoundationPileWidget({super.key, required this.pile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: pile.isEmpty
            ? Text(
                'A',
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              )
            : CardWidget(card: pile.topCardThrow),
      ),
    );
  }
}
