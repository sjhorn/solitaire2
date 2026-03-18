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
            left: 8,
            top: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.rank.toStringValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  card.suit.symbol,
                  style: TextStyle(
                    fontSize: 16,
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
            right: 8,
            bottom: 8,
            child: Transform.rotate(
              angle: 180 * 3.14159 / 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    card.rank.toStringValue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    card.suit.symbol,
                    style: TextStyle(
                      fontSize: 16,
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
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }

    // For number cards, show pip layout
    return _PipLayout(suit: card.suit, rank: card.rank, color: color);
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
        color: const Color(0xFF1E3A5F),
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

  const _PipLayout({
    required this.suit,
    required this.rank,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pipCount = rank.value;

    switch (pipCount) {
      case 1:
        return _SinglePip(suit: suit, color: color);
      case 2:
      case 3:
      case 4:
      case 5:
        return _SmallPipLayout(suit: suit, pipCount: pipCount, color: color);
      case 6:
        return _SixPipLayout(suit: suit, color: color);
      case 7:
        return _SevenPipLayout(suit: suit, color: color);
      case 8:
        return _EightPipLayout(suit: suit, color: color);
      case 9:
        return _NinePipLayout(suit: suit, color: color);
      case 10:
        return _TenPipLayout(suit: suit, color: color);
      default:
        return Text(
          suit.symbol,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );
    }
  }
}

/// Single pip in the center (for Ace).
class _SinglePip extends StatelessWidget {
  final CardSuit suit;
  final Color color;

  const _SinglePip({required this.suit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      suit.symbol,
      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
    );
  }
}

/// Layout for 2-5 pips.
class _SmallPipLayout extends StatelessWidget {
  final CardSuit suit;
  final int pipCount;
  final Color color;

  const _SmallPipLayout({
    required this.suit,
    required this.pipCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pipSize = constraints.maxWidth / 3;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pipCount,
            (index) => Center(
              child: Text(
                suit.symbol,
                style: TextStyle(
                  fontSize: pipSize * 0.6,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Layout for 6 pips (2 columns of 3).
class _SixPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;

  const _SixPipLayout({required this.suit, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pipSize = constraints.maxWidth / 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.filled(
                3,
                Text(
                  suit.symbol,
                  style: TextStyle(
                    fontSize: pipSize * 0.6,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.filled(
                3,
                Text(
                  suit.symbol,
                  style: TextStyle(
                    fontSize: pipSize * 0.6,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Layout for 7 pips (6 around center).
class _SevenPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;

  const _SevenPipLayout({required this.suit, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pipSize = constraints.maxWidth / 3;
        return Stack(
          children: [
            // Left column (3)
            Positioned(
              left: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            // Center (1)
            Positioned(
              left: constraints.maxWidth / 2 - 10,
              top: constraints.maxHeight / 2 - 10,
              child: Text(
                suit.symbol,
                style: TextStyle(
                  fontSize: pipSize * 0.6,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            // Right column (3)
            Positioned(
              right: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Layout for 8 pips (6 around, 2 extra).
class _EightPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;

  const _EightPipLayout({required this.suit, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pipSize = constraints.maxWidth / 3;
        return Stack(
          children: [
            // Left column (3)
            Positioned(
              left: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            // Center (2)
            Positioned(
              left: constraints.maxWidth / 2 - 15,
              top: constraints.maxHeight / 3,
              child: Text(
                suit.symbol,
                style: TextStyle(
                  fontSize: pipSize * 0.6,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Positioned(
              left: constraints.maxWidth / 2 - 15,
              top: constraints.maxHeight * 2 / 3 - 10,
              child: Text(
                suit.symbol,
                style: TextStyle(
                  fontSize: pipSize * 0.6,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            // Right column (3)
            Positioned(
              right: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Layout for 9 pips (8 around, 1 center).
class _NinePipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;

  const _NinePipLayout({required this.suit, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pipSize = constraints.maxWidth / 3;
        return Stack(
          children: [
            // Left column (3)
            Positioned(
              left: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            // Center (1)
            Positioned(
              left: constraints.maxWidth / 2 - 10,
              top: constraints.maxHeight / 2 - 10,
              child: Text(
                suit.symbol,
                style: TextStyle(
                  fontSize: pipSize * 0.6,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            // Right column (3)
            Positioned(
              right: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Layout for 10 pips (4 columns of 2 or 2 columns of 5).
class _TenPipLayout extends StatelessWidget {
  final CardSuit suit;
  final Color color;

  const _TenPipLayout({required this.suit, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pipSize = constraints.maxWidth / 3;
        return Stack(
          children: [
            // Left column (3)
            Positioned(
              left: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            // Center left (2)
            Positioned(
              left: constraints.maxWidth / 3 - 15,
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.15),
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.4),
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            // Center right (2)
            Positioned(
              left: constraints.maxWidth * 2 / 3 - 15,
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.15),
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.4),
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            // Right column (3)
            Positioned(
              right: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.filled(
                  3,
                  Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: pipSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
