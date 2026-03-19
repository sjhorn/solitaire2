import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/playing_card.dart';

/// A widget that renders a playing card.
///
/// Displays either the face of the card (showing rank and suit) or the back
/// design depending on the [PlayingCard.faceUp] property.
class CardWidget extends StatelessWidget {
  /// The card to display.
  final PlayingCard card;

  /// The size of the card (default is 80x120 pixels).
  final Size size;

  const CardWidget({
    super.key,
    required this.card,
    this.size = const Size(80, 120),
  });

  @override
  Widget build(BuildContext context) {
    if (!card.faceUp) {
      return _CardBack(size: size);
    }

    final isRed =
        card.suit == CardSuit.hearts || card.suit == CardSuit.diamonds;
    final color = isRed ? Colors.red : Colors.black;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: card.isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Top-left rank and suit
          Positioned(
            left: 6,
            top: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.rank.toStringValue,
                  style: TextStyle(
                    fontSize: size.width * 0.2,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  card.suit.symbol,
                  style: TextStyle(
                    fontSize: size.width * 0.2,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Center suit symbol or pip layout
          Center(child: _buildCenterContent(color)),

          // Bottom-right rank and suit (rotated)
          Positioned(
            right: 6,
            bottom: 4,
            child: Transform.rotate(
              angle: 180 * 3.14159 / 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    card.rank.toStringValue,
                    style: TextStyle(
                      fontSize: size.width * 0.2,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    card.suit.symbol,
                    style: TextStyle(
                      fontSize: size.width * 0.2,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent(Color color) {
    // For face cards (J, Q, K), show large suit symbol
    if (card.rank == CardRank.jack ||
        card.rank == CardRank.queen ||
        card.rank == CardRank.king) {
      return Text(
        card.suit.symbol,
        style: TextStyle(
          fontSize: size.width * 0.6,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }

    // For number cards, show pip layout
    return _PipLayout(suit: card.suit, rank: card.rank, color: color, size: size);
  }
}

/// A decorative card back design using a pattern.
class _CardBack extends StatelessWidget {
  final Size size;

  const _CardBack({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CustomPaint(painter: _CardBackPatternPainter()),
    );
  }
}

/// A custom painter that draws a decorative pattern on the card back.
class _CardBackPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(77)
      ..style = PaintingStyle.fill;

    final patternSize = 10.0;
    final cols = (size.width / patternSize).ceil();
    final rows = (size.height / patternSize).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * patternSize;
        final y = row * patternSize;
        final isEven = (row + col) % 2 == 0;

        if (isEven) {
          // Draw small diamond
          final path = Path()
            ..moveTo(x + patternSize / 2, y + 2)
            ..lineTo(x + patternSize - 2, y + patternSize / 2)
            ..lineTo(x + patternSize / 2, y + patternSize - 2)
            ..lineTo(x + 2, y + patternSize / 2)
            ..close();
          canvas.drawPath(path, paint);
        } else {
          // Draw small circle
          canvas.drawCircle(
            Offset(x + patternSize / 2, y + patternSize / 2),
            2,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A pip layout widget that displays the correct pip arrangement for number cards.
class _PipLayout extends StatelessWidget {
  final CardSuit suit;
  final CardRank rank;
  final Color color;
  final Size size;

  const _PipLayout({
    required this.suit,
    required this.rank,
    required this.color,
    required this.size,
  });

  double get _pipSize => size.width * 0.18;

  @override
  Widget build(BuildContext context) {
    final pipCount = rank.value;

    switch (pipCount) {
      case 1:
        return _SinglePip(suit: suit, color: color, pipSize: _pipSize);
      case 2:
        return _TwoPipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 3:
        return _ThreePipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 4:
        return _FourPipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 5:
        return _FivePipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 6:
        return _SixPipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 7:
        return _SevenPipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 8:
        return _EightPipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 9:
        return _NinePipLayout(suit: suit, color: color, pipSize: _pipSize);
      case 10:
        return _TenPipLayout(suit: suit, color: color, pipSize: _pipSize);
    }
    // Should never reach here given CardRank values 1-13
    throw UnsupportedError('Unsupported pip count: $pipCount');
  }
}

/// Single pip in the center (for Ace).
class _SinglePip extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _SinglePip({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      suit.symbol,
      style: TextStyle(fontSize: pipSize * 2, fontWeight: FontWeight.bold, color: color),
    );
  }
}

/// Layout for 2 pips (vertical).
class _TwoPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _TwoPipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(suit.symbol, style: _pipStyle()),
        SizedBox(height: pipSize),
        Text(suit.symbol, style: _pipStyle()),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 3 pips (vertical with center).
class _ThreePipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _ThreePipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(suit.symbol, style: _pipStyle()),
        SizedBox(height: pipSize),
        Text(suit.symbol, style: _pipStyle()),
        SizedBox(height: pipSize),
        Text(suit.symbol, style: _pipStyle()),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 4 pips (corners).
class _FourPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _FourPipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 5 pips (4 corners + center).
class _FivePipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _FivePipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Center(child: Text(suit.symbol, style: _pipStyle())),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 6 pips (2 columns of 3).
class _SixPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _SixPipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.filled(3, Text(suit.symbol, style: _pipStyle())),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.filled(3, Text(suit.symbol, style: _pipStyle())),
        ),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 7 pips (2 columns of 3 + 1 center).
class _SevenPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _SevenPipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 0, top: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: 0, bottom: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, top: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, bottom: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: pipSize, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Center(child: Text(suit.symbol, style: _pipStyle())),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 8 pips (2 columns of 3 + 2 center).
class _EightPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _EightPipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize, top: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize, bottom: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: pipSize, top: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: pipSize, bottom: pipSize, child: Text(suit.symbol, style: _pipStyle())),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 9 pips (4 corners + 4 middle + 1 center).
class _NinePipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _NinePipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: pipSize, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: pipSize, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Center(child: Text(suit.symbol, style: _pipStyle())),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}

/// Layout for 10 pips (4 corners + 6 middle).
class _TenPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;
  final double pipSize;

  const _TenPipLayout({required this.suit, required this.color, required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize, top: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize, bottom: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: 0, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: pipSize, top: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(right: pipSize, bottom: pipSize, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize * 1.5, top: 0, child: Text(suit.symbol, style: _pipStyle())),
        Positioned(left: pipSize * 1.5, bottom: 0, child: Text(suit.symbol, style: _pipStyle())),
      ],
    );
  }

  TextStyle _pipStyle() => TextStyle(fontSize: pipSize, fontWeight: FontWeight.bold, color: color);
}
