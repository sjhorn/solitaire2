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
import 'package:solitaire/src/widgets/card_widget.dart';
import 'package:solitaire/src/widgets/foundation_pile_widget.dart';
import 'package:solitaire/src/widgets/stock_pile_widget.dart';
import 'package:solitaire/src/widgets/tableau_pile_widget.dart';
import 'package:solitaire/src/widgets/waste_pile_widget.dart';

void main() {
  group('FoundationPileWidget', () {
    testWidgets('shows empty placeholder "A"', (tester) async {
      final emptyPile = GamePile(type: PileType.foundations);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoundationPileWidget(pile: emptyPile),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('A'), findsOneWidget);
      expect(find.byType(CardWidget), findsNothing);
    });

    testWidgets('shows card when pile has card', (tester) async {
      final filledPile = GamePile(type: PileType.foundations);
      filledPile.addCard(
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, faceUp: true),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoundationPileWidget(pile: filledPile),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('A'), findsNothing);
      expect(find.byType(CardWidget), findsOneWidget);
    });

    testWidgets('shows correct card suit and color', (tester) async {
      final filledPile = GamePile(type: PileType.foundations);
      filledPile.addCard(
        PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: true),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoundationPileWidget(pile: filledPile),
          ),
        ),
      );
      await tester.pump();

      final cardWidget = find.byType(CardWidget).evaluate().first;
      expect(cardWidget, isNotNull);
    });
  });

  group('BoardWidget', () {
    testWidgets('renders with 7 tableau piles', (tester) async {
      final tableauPiles = List.generate(
        7,
        (index) => GamePile(type: PileType.tableau),
      );
      for (var i = 0; i < 7; i++) {
        tableauPiles[i].addCard(
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, faceUp: true),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardWidget(
              gameState: _createGameState(tableauPiles),
              onStockTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TableauPileWidget), findsNWidgets(7));
    });

    testWidgets('renders with 4 foundation piles', (tester) async {
      final foundationPiles = List.generate(
        4,
        (index) => GamePile(type: PileType.foundations),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardWidget(
              gameState: _createGameState([], foundationPiles),
              onStockTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FoundationPileWidget), findsNWidgets(4));
    });

    testWidgets('renders stock and waste piles', (tester) async {
      final tableauPiles = List.generate(7, (index) => GamePile(type: PileType.tableau));
      final stockPile = GamePile(type: PileType.stock);
      final wastePile = GamePile(type: PileType.waste);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardWidget(
              gameState: _createGameState(tableauPiles, [], stockPile, wastePile),
              onStockTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(StockPileWidget), findsOneWidget);
      expect(find.byType(WastePileWidget), findsOneWidget);
    });
  });

  group('StockPileWidget', () {
    testWidgets('shows empty state when pile is empty', (tester) async {
      final emptyPile = GamePile(type: PileType.stock);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockPileWidget(pile: emptyPile, onTap: () {}),
          ),
        ),
      );
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.child, isNull);
    });

    testWidgets('renders cards when pile has cards', (tester) async {
      final stockPile = GamePile(type: PileType.stock);
      stockPile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: false));
      stockPile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, faceUp: false));
      stockPile.addCard(PlayingCard(suit: CardSuit.diamonds, rank: CardRank.queen, faceUp: false));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockPileWidget(pile: stockPile, onTap: () {}),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CardWidget), findsNWidgets(3));
    });

    testWidgets('disables tap when pile is empty', (tester) async {
      final emptyPile = GamePile(type: PileType.stock);
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockPileWidget(
              pile: emptyPile,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(wasTapped, false);
    });

    testWidgets('enables tap when pile has cards', (tester) async {
      final stockPile = GamePile(type: PileType.stock);
      stockPile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: false));
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockPileWidget(
              pile: stockPile,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(wasTapped, true);
    });
  });

  group('WastePileWidget', () {
    testWidgets('shows empty state when pile is empty', (tester) async {
      final emptyPile = GamePile(type: PileType.waste);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WastePileWidget(pile: emptyPile),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CardWidget), findsNothing);
    });

    testWidgets('shows card when pile has card', (tester) async {
      final wastePile = GamePile(type: PileType.waste);
      wastePile.addCard(
        PlayingCard(suit: CardSuit.clubs, rank: CardRank.ten, faceUp: true),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WastePileWidget(pile: wastePile),
          ),
        ),
      );
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.child, isNotNull);
    });

    testWidgets('displays top card correctly', (tester) async {
      final wastePile = GamePile(type: PileType.waste);
      final testCard = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.jack, faceUp: true);
      wastePile.addCard(testCard);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WastePileWidget(pile: wastePile),
          ),
        ),
      );
      await tester.pump();

      final cardWidgets = find.byType(CardWidget).evaluate().toList();
      expect(cardWidgets.length, 1);
    });
  });

  group('TableauPileWidget', () {
    testWidgets('renders cards with overlap', (tester) async {
      final pile = GamePile(type: PileType.tableau);
      pile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.king, faceUp: true));
      pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen, faceUp: true));
      pile.addCard(PlayingCard(suit: CardSuit.clubs, rank: CardRank.jack, faceUp: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableauPileWidget(pile: pile, xOffset: 0),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CardWidget), findsNWidgets(3));
    });

    testWidgets('renders single card without Draggable', (tester) async {
      final pile = GamePile(type: PileType.tableau);
      pile.addCard(PlayingCard(suit: CardSuit.diamonds, rank: CardRank.ten, faceUp: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableauPileWidget(pile: pile, xOffset: 0),
          ),
        ),
      );
      await tester.pump();

      // Top card should be draggable
      expect(find.byType(Draggable), findsOneWidget);
    });

    testWidgets('renders face-down cards without Draggable', (tester) async {
      final pile = GamePile(type: PileType.tableau);
      pile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: false));
      pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, faceUp: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableauPileWidget(pile: pile, xOffset: 0),
          ),
        ),
      );
      await tester.pump();

      // Only top card should be draggable
      expect(find.byType(Draggable), findsOneWidget);
    });

    testWidgets('positions cards with 30px overlap', (tester) async {
      final pile = GamePile(type: PileType.tableau);
      pile.addCard(PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, faceUp: true));
      pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, faceUp: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableauPileWidget(pile: pile, xOffset: 0),
          ),
        ),
      );
      await tester.pump();

      final stacks = find.byType(Stack).evaluate().toList();
      expect(stacks.length, 2); // One for the main widget, one for Draggable feedback
    });

    testWidgets('shows correct number of cards for empty pile', (tester) async {
      final pile = GamePile(type: PileType.tableau);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableauPileWidget(pile: pile, xOffset: 0),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CardWidget), findsNothing);
    });
  });
}

GameState _createGameState(
  List<GamePile> tableauPiles, [
  List<GamePile>? foundationPiles,
  GamePile? stockPile,
  GamePile? wastePile,
]) {
  foundationPiles ??= List.generate(4, (index) => GamePile(type: PileType.foundations));
  stockPile ??= GamePile(type: PileType.stock);
  wastePile ??= GamePile(type: PileType.waste);

  return GameState.createWithPiles(
    deck: Deck(),
    tableauPiles: tableauPiles,
    foundationPiles: foundationPiles,
    stockPile: stockPile,
    wastePile: wastePile,
  );
}
