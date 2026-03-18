import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_state.dart';
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
      ),
    );
  }
}
