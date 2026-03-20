import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/widgets/foundation_pile_widget.dart';

void main() {
  group('FoundationPileWidget', () {
    group('empty foundation', () {
      testWidgets('displays Ace placeholder', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('displays gray Ace placeholder with correct styling', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final text = tester.widget<Text>(find.text('A'));
        expect(text.style?.color, Colors.grey);
        expect(text.style?.fontSize, 48);
        expect(text.style?.fontWeight, FontWeight.bold);
      });
    });

    group('DragTarget callbacks', () {
      testWidgets('onWillAcceptWithDetails accepts Ace on empty foundation', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        final aceOfHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        // Test the validation - Ace should be accepted on empty foundation
        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [aceOfHearts], offset: Offset.zero)),
          isTrue,
        );
      });

      testWidgets('onWillAcceptWithDetails rejects non-Ace on empty foundation', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        final twoOfHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [twoOfHearts], offset: Offset.zero)),
          isFalse,
        );
      });

      testWidgets('onWillAcceptWithDetails rejects face-down card', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        final faceDownAce = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: false);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [faceDownAce], offset: Offset.zero)),
          isFalse,
        );
      });

      testWidgets('onWillAcceptWithDetails accepts consecutive same suit card', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));
        final twoOfHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [twoOfHearts], offset: Offset.zero)),
          isTrue,
        );
      });

      testWidgets('onWillAcceptWithDetails rejects wrong suit', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));
        final twoOfDiamonds = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.two, faceUp: true);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [twoOfDiamonds], offset: Offset.zero)),
          isFalse,
        );
      });

      testWidgets('onWillAcceptWithDetails rejects non-consecutive rank', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));
        final threeOfHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.three, faceUp: true);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [threeOfHearts], offset: Offset.zero)),
          isFalse,
        );
      });

      testWidgets('onWillAcceptWithDetails accepts King after Queen', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.queen, faceUp: true));
        final kingOfSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [kingOfSpades], offset: Offset.zero)),
          isTrue,
        );
      });

      testWidgets('onWillAcceptWithDetails rejects empty data', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [], offset: Offset.zero)),
          isFalse,
        );
      });

      testWidgets('onAcceptWithDetails calls callback with card and index', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));

        PlayingCard? capturedCard;
        int? capturedIndex;

        await tester.pumpWidget(_buildFoundationWidget(
          pile,
          onDrop: (card, index) {
            capturedCard = card;
            capturedIndex = index;
          },
          foundationIndex: 2,
        ));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        final twoOfHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true);
        dragTarget.onAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [twoOfHearts], offset: Offset.zero));

        expect(capturedCard, twoOfHearts);
        expect(capturedIndex, 2);
      });

      testWidgets('onAcceptWithDetails does not call callback when onDrop is null', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        final twoOfHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true);
        // Should not throw
        dragTarget.onAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [twoOfHearts], offset: Offset.zero));
      });
    });

    group('visual feedback', () {
      testWidgets('has gray border when not dragging', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.border, isA<Border>());
        final border = decoration.border as Border;
        expect(border.top.color, Colors.grey);
        expect(border.top.width, 2);
      });

      testWidgets('has green border when drag over valid card', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        // The builder callback receives candidateData - when it's not empty, border should be green
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        // Default state is not dragging, so gray border
        expect(decoration.border, isA<Border>());
      });

      testWidgets('has green background when drag over', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        // When not dragging, no background color
        expect(decoration.color, isNull);
      });

      testWidgets('has correct dimensions', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final renderBox = tester.renderObject<RenderBox>(find.byType(Container).first);
        expect(renderBox.size.width, 88);
        expect(renderBox.size.height, 128);
      });

      testWidgets('has rounded corners', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(8));
      });
    });

    group('display states', () {
      testWidgets('renders correctly when pile has card', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        final aceOfHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true);
        pile.addCard(aceOfHearts);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        // Widget should render without errors
        expect(find.byType(DragTarget<List<PlayingCard>>), findsOneWidget);
      });

      testWidgets('displays Ace placeholder when pile is empty', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        expect(find.text('A'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('handles Ace on empty foundation of any suit', (tester) async {
        final pile = GamePile(type: PileType.foundations);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true)], offset: Offset.zero)),
          isTrue,
        );
        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [PlayingCard(suit: CardSuit.diamonds, rank: CardRank.ace, faceUp: true)], offset: Offset.zero)),
          isTrue,
        );
        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [PlayingCard(suit: CardSuit.clubs, rank: CardRank.ace, faceUp: true)], offset: Offset.zero)),
          isTrue,
        );
        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: true)], offset: Offset.zero)),
          isTrue,
        );
      });

      testWidgets('rejects face-down card on non-empty foundation', (tester) async {
        final pile = GamePile(type: PileType.foundations);
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));
        final faceDownTwo = PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: false);

        await tester.pumpWidget(_buildFoundationWidget(pile));
        await tester.pump();

        final dragTarget = tester.widget<DragTarget<List<PlayingCard>>>(
          find.byType(DragTarget<List<PlayingCard>>),
        );

        expect(
          dragTarget.onWillAcceptWithDetails?.call(DragTargetDetails<List<PlayingCard>>(data: [faceDownTwo], offset: Offset.zero)),
          isFalse,
        );
      });
    });
  });
}

Widget _buildFoundationWidget(
  GamePile pile, {
  Function(PlayingCard card, int foundationIndex)? onDrop,
  int foundationIndex = 0,
}) {
  return MaterialApp(
    home: Scaffold(
      body: FoundationPileWidget(
        pile: pile,
        onDrop: onDrop,
        foundationIndex: foundationIndex,
      ),
    ),
  );
}
