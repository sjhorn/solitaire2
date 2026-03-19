import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

/// A card widget with flip animation support.
///
/// This widget animates the transition between face-up and face-down states
/// using a 3D-like flip animation.
class AnimatedCardWidget extends StatefulWidget {
  /// The card to display.
  final PlayingCard card;

  /// The size of the card (default is 80x120 pixels).
  final Size size;

  /// Duration of the flip animation.
  final Duration flipDuration;

  const AnimatedCardWidget({
    super.key,
    required this.card,
    this.size = const Size(80, 120),
    this.flipDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedCardWidget> createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState extends State<AnimatedCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start animation based on initial state
    if (!widget.card.faceUp) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.faceUp != widget.card.faceUp) {
      if (widget.card.faceUp) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final halfTurn = _animation.value * 3.14159 / 2; // 0 to 90 degrees

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Add perspective
            ..rotateY(halfTurn),
          child: Opacity(
            opacity: _animation.value == 0.0 ? 0.0 : 1.0,
            child: child,
          ),
        );
      },
      child: CardWidget(card: widget.card, size: widget.size),
    );
  }
}
