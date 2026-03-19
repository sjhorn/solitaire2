import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/widgets/board_widget.dart';

void main() {
  runApp(const SolitaireApp());
}

class SolitaireApp extends StatelessWidget {
  const SolitaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solitaire',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SolitaireHome(),
    );
  }
}

class SolitaireHome extends StatefulWidget {
  const SolitaireHome({super.key});

  @override
  State<SolitaireHome> createState() => _SolitaireHomeState();
}

class _SolitaireHomeState extends State<SolitaireHome> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = GameState.initial();
  }

  void _drawFromStock() {
    setState(() {
      _gameState = _gameState.drawFromStock();
    });
  }

  void _dropOnFoundation(PlayingCard card, int foundationIndex) {
    setState(() {
      // Try moving from waste to foundation
      var newGameState = _gameState.moveWasteToFoundation(foundationIndex);
      if (newGameState != null) {
        _gameState = newGameState;
        return;
      }

      // Try moving from tableau to foundation
      for (var tableauIndex = 0; tableauIndex < 7; tableauIndex++) {
        newGameState = _gameState.moveTableauToFoundation(tableauIndex, foundationIndex);
        if (newGameState != null) {
          _gameState = newGameState;
          return;
        }
      }
    });
  }

  void _dropOnTableau(PlayingCard card, int tableauIndex) {
    setState(() {
      // Try moving from waste to tableau
      var newGameState = _gameState.moveWasteToTableau(tableauIndex);
      if (newGameState != null) {
        _gameState = newGameState;
        return;
      }

      // Try moving from foundation to tableau
      for (var foundationIndex = 0; foundationIndex < 4; foundationIndex++) {
        newGameState = _gameState.moveFoundationToTableau(foundationIndex, tableauIndex);
        if (newGameState != null) {
          _gameState = newGameState;
          return;
        }
      }

      // Try moving from one tableau to another
      for (var fromTableauIndex = 0; fromTableauIndex < 7; fromTableauIndex++) {
        if (fromTableauIndex == tableauIndex) continue;
        newGameState = _gameState.moveTableauToTableau(fromTableauIndex, tableauIndex);
        if (newGameState != null) {
          _gameState = newGameState;
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solitaire'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BoardWidget(
        gameState: _gameState,
        onStockTap: _drawFromStock,
        onDropOnFoundation: _dropOnFoundation,
        onDropOnTableau: _dropOnTableau,
      ),
    );
  }
}
