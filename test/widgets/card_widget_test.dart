import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/card_widget.dart';

void main() {
  group('CardWidget', () {
    group('face-up cards', () {
      testWidgets('displays correct rank and suit symbol', (tester) async {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);

        await tester.pumpWidget(_buildCardWidget(card));
        await tester.pump();

        expect(find.text('A'), findsNWidgets(2)); // top-left and bottom-right
        expect(
          find.text('♥'),
          findsNWidgets(3),
        ); // top-left, center, bottom-right
      });

      testWidgets('displays red color for red suits', (tester) async {
        final heartCard = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.king,
        );

        await tester.pumpWidget(_buildCardWidget(heartCard));
        await tester.pump();

        var redTexts = tester
            .widgetList<Text>(find.byType(Text))
            .where((t) => t.style?.color == Colors.red);
        expect(redTexts.isNotEmpty, isTrue);
      });

      testWidgets('displays black color for black suits', (tester) async {
        final spadeCard = PlayingCard(
          suit: CardSuit.spades,
          rank: CardRank.jack,
        );

        await tester.pumpWidget(_buildCardWidget(spadeCard));
        await tester.pump();

        var blackTexts = tester
            .widgetList<Text>(find.byType(Text))
            .where((t) => t.style?.color == Colors.black);
        expect(blackTexts.isNotEmpty, isTrue);
      });

      testWidgets('displays pip layout for number cards', (tester) async {
        final threeOfHearts = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.three,
        );

        await tester.pumpWidget(_buildCardWidget(threeOfHearts));
        await tester.pump();

        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts.length, greaterThanOrEqualTo(3));
      });
    });

    group('face-down cards', () {
      testWidgets('displays card back design when face-down', (tester) async {
        final card = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.ace,
          faceUp: false,
        );

        await tester.pumpWidget(_buildCardWidget(card));
        await tester.pump();

        // Face-down card should not show rank text, but should show custom paint
        expect(find.text('A'), findsNothing);
        expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
      });
    });

    group('selected state', () {
      testWidgets('applies elevation shadow when selected', (tester) async {
        final card = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.ace,
          isSelected: true,
        );

        await tester.pumpWidget(_buildCardWidget(card));
        await tester.pump();

        // Find the card container and check for shadow
        final containers = tester
            .widgetList<Container>(find.byType(Container))
            .toList();
        bool hasShadow = false;
        for (var container in containers) {
          if (container.decoration is BoxDecoration) {
            final boxDecoration = container.decoration as BoxDecoration;
            if (boxDecoration.boxShadow?.isNotEmpty == true) {
              hasShadow = true;
              break;
            }
          }
        }
        expect(hasShadow, isTrue);
      });
    });
  });
}

Widget _buildCardWidget(PlayingCard card) {
  return MaterialApp(
    home: Scaffold(body: CardWidget(card: card)),
  );
}
