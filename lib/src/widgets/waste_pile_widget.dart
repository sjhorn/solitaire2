import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A widget that displays the waste pile.
///
/// The waste pile contains cards that have been drawn from the stock.
class WastePileWidget extends StatelessWidget {
  /// The waste pile containing cards.
  final GamePile pile;

  const WastePileWidget({super.key, required this.pile});

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
      child: pile.isEmpty
          ? const SizedBox.shrink()
          : CardWidget(card: pile.topCardThrow),
    );
  }
}
