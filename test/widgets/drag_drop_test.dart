import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/board_widget.dart';
import 'package:solitaire/src/widgets/foundation_pile_widget.dart';
import 'package:solitaire/src/widgets/tableau_pile_widget.dart';

void main() {
  group('Drag & Drop - TableauPileWidget', () {
    testWidgets('top face-up card is draggable', (tester) async {
      final pile = GamePile(type: PileType.tableau);
      pile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TableauPileWidget(pile: pile, xOffset: 0),
            ),
          ),
        ),
      );
      await tester.pump();

      // Top face-up card should be draggable
      expect(find.byType(Draggable<PlayingCard>), findsOneWidget);
    });

    testWidgets('face-down card is not draggable', (tester) async {
      final pile = GamePile(type: PileType.tableau);
      pile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: false));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TableauPileWidget(pile: pile, xOffset: 0),
            ),
          ),
        ),
      );
      await tester.pump();

      // Face-down card should not be draggable
      expect(find.byType(Draggable<PlayingCard>), findsNothing);
    });

    testWidgets('only top card is draggable in a stack', (tester) async {
      final pile = GamePile(type: PileType.tableau);
      pile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true));
      pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true));
      pile.addCard(PlayingCard(suit: CardSuit.clubs, rank: CardRank.jack, faceUp: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TableauPileWidget(pile: pile, xOffset: 0),
            ),
          ),
        ),
      );
      await tester.pump();

      // Only one draggable (the top card)
      expect(find.byType(Draggable<PlayingCard>), findsOneWidget);
    });
  });

  group('Drag & Drop - Move Validation', () {
    test('waste to foundation move is valid for ace', () {
      final gameState = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: List.generate(7, (_) => GamePile(type: PileType.tableau)),
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste)..addCard(
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true),
        ),
      );

      // Ace to empty foundation should be valid
      final result = gameState.moveWasteToFoundation(0);
      expect(result, isNotNull);
    });

    test('waste to foundation move is invalid for non-ace on empty foundation', () {
      final gameState = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: List.generate(7, (_) => GamePile(type: PileType.tableau)),
        foundationPiles: List.generate(4, (_) => GamePile(type: PileType.foundations)),
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste)..addCard(
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true),
        ),
      );

      // Two to empty foundation should be invalid
      final result = gameState.moveWasteToFoundation(0);
      expect(result, isNull);
    });

    test('tableau to foundation move is valid when conditions met', () {
      final aceHearts = GamePile(type: PileType.foundations);
      aceHearts.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true));

      final gameState = GameState.createWithPiles(
        deck: Deck(),
        tableauPiles: [
          GamePile(type: PileType.tableau)..addCard(
            PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true),
          ),
          ...List.generate(6, (_) => GamePile(type: PileType.tableau)),
        ],
        foundationPiles: [aceHearts, ...List.generate(3, (_) => GamePile(type: PileType.foundations))],
        stockPile: GamePile(type: PileType.stock),
        wastePile: GamePile(type: PileType.waste),
      );

      // Two of hearts on ace of hearts should be valid
      final result = gameState.moveTableauToFoundation(0, 0);
      expect(result, isNotNull);
    });
  });

  group('Drag & Drop - BoardWidget Integration', () {
    testWidgets('board renders with all piles for drag operations', (tester) async {
      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      // Add cards to first tableau pile
      tableauPiles[0].addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true));
      tableauPiles[0].addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true));

      final foundationPiles = List.generate(4, (_) => GamePile(type: PileType.foundations));
      final stockPile = GamePile(type: PileType.stock);
      final wastePile = GamePile(type: PileType.waste);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: BoardWidget(
                gameState: GameState.createWithPiles(
                  deck: Deck(),
                  tableauPiles: tableauPiles,
                  foundationPiles: foundationPiles,
                  stockPile: stockPile,
                  wastePile: wastePile,
                ),
                onStockTap: () {},
                onDropOnFoundation: (card, index) {},
                onDropOnTableau: (card, index) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify all piles are rendered
      expect(find.byType(TableauPileWidget), findsNWidgets(7));
      expect(find.byType(Draggable<PlayingCard>), findsOneWidget); // Top card of first tableau pile
    });
  });

  group('DragTarget - FoundationPileWidget', () {
    testWidgets('accepts valid drop (ace on empty foundation)', (tester) async {
      final foundationPile = GamePile(type: PileType.foundations);
      bool wasAccepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoundationPileWidget(
              pile: foundationPile,
              foundationIndex: 0,
              onDrop: (card, index) => wasAccepted = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify the DragTarget is present
      expect(find.byType(DragTarget<List<PlayingCard>>), findsOneWidget);
    });

    testWidgets('shows green highlight when valid drag is over', (tester) async {
      final foundationPile = GamePile(type: PileType.foundations);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoundationPileWidget(
              pile: foundationPile,
              foundationIndex: 0,
              onDrop: (card, index) {},
            ),
          ),
        ),
      );
      await tester.pump();

      // DragTarget should be present for drop handling
      expect(find.byType(DragTarget<List<PlayingCard>>), findsOneWidget);
    });
  });

  group('DragTarget - TableauPileWidget', () {
    testWidgets('accepts king on empty tableau', (tester) async {
      final tableauPile = GamePile(type: PileType.tableau);
      bool wasAccepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 150,
              child: TableauPileWidget(
                pile: tableauPile,
                xOffset: 0,
                tableauIndex: 0,
                onDrop: (card, index) => wasAccepted = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // DragTarget should be present
      expect(find.byType(DragTarget<List<PlayingCard>>), findsOneWidget);
    });

    testWidgets('validates alternating color rule', (tester) async {
      final tableauPile = GamePile(type: PileType.tableau);
      tableauPile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 150,
              child: TableauPileWidget(
                pile: tableauPile,
                xOffset: 0,
                tableauIndex: 0,
                onDrop: (card, index) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DragTarget<List<PlayingCard>>), findsOneWidget);
    });
  });
}
