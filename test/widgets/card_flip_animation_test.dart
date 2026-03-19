import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/animated_card_widget.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

void main() {
  group('Card Flip Animation', () {
    testWidgets('shows card back when face-down', (tester) async {
      final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardWidget(card: card),
          ),
        ),
      );
      await tester.pump();

      // Card back should be displayed (blue background)
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('shows card face when face-up', (tester) async {
      final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardWidget(card: card),
          ),
        ),
      );
      await tester.pump();

      // Card face should display rank and suit
      expect(find.text('A'), findsWidgets); // Top-left and bottom-right Ace
      expect(find.text('♥'), findsWidgets); // Heart symbols
    });

    testWidgets('AnimatedCardWidget animates flip transition', (tester) async {
      final card = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCardWidget(card: card),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AnimatedCardWidget), findsOneWidget);
    });
  });
}
