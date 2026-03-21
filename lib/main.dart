import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_service.dart';
import 'package:solitaire/src/domain/playing_card.dart';
import 'package:solitaire/src/hint_service.dart';
import 'package:solitaire/src/screens/settings_screen.dart';
import 'package:solitaire/src/services/audio_service.dart';
import 'package:solitaire/src/widgets/board_widget.dart';
import 'package:solitaire/src/widgets/control_buttons_widget.dart';
import 'package:solitaire/src/widgets/score_display_widget.dart';

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
  late GameService _gameService;
  late AudioService _audioService;
  Timer? _timer;
  Hint? _currentHint;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _startNewGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _startNewGame() {
    _gameService = GameService.newGame();
    _currentHint = null;
    _startTimer();
  }

  void _drawCard() {
    _gameService.drawCard();
    _audioService.playStockTap();
    _audioService.triggerHaptic();
    setState(() {});
  }

  void _dropOnFoundation(PlayingCard card, int foundationIndex) {
    // Try moving from waste to foundation
    var result = _gameService.moveWasteToFoundation(foundationIndex);
    if (result != null) {
      _gameService = result;
      _audioService.playCardPlace();
      _audioService.triggerHaptic();
      _checkWin();
      setState(() {});
      return;
    }

    // Try moving from tableau to foundation
    for (var tableauIndex = 0; tableauIndex < 7; tableauIndex++) {
      result = _gameService.moveTableauToFoundation(tableauIndex, foundationIndex);
      if (result != null) {
        _gameService = result;
        _audioService.playCardPlace();
        _audioService.triggerHaptic();
        _checkWin();
        setState(() {});
        return;
      }
    }

    // Move rejected
    _audioService.playMoveRejected();
  }

  void _dropOnTableau(PlayingCard card, int tableauIndex) {
    // Try moving from waste to tableau
    var result = _gameService.moveWasteToTableau(tableauIndex);
    if (result != null) {
      _gameService = result;
      _audioService.playCardSlide();
      _audioService.triggerHaptic();
      _checkWin();
      setState(() {});
      return;
    }

    // Try moving from foundation to tableau
    for (var foundationIndex = 0; foundationIndex < 4; foundationIndex++) {
      result = _gameService.moveFoundationToTableau(foundationIndex, tableauIndex);
      if (result != null) {
        _gameService = result;
        _audioService.playCardSlide();
        _audioService.triggerHaptic();
        _checkWin();
        setState(() {});
        return;
      }
    }

    // Try moving from one tableau to another
    for (var fromTableauIndex = 0; fromTableauIndex < 7; fromTableauIndex++) {
      if (fromTableauIndex == tableauIndex) continue;
      result = _gameService.moveTableauToTableau(fromTableauIndex, tableauIndex);
      if (result != null) {
        _gameService = result;
        _audioService.playCardSlide();
        _audioService.triggerHaptic();
        _checkWin();
        setState(() {});
        return;
      }
    }

    // Move rejected
    _audioService.playMoveRejected();
  }

  void _checkWin() {
    if (_gameService.isWon) {
      _gameService.markWon();
      _audioService.playWinFanfare();
      _audioService.triggerHeavyHaptic();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congratulations! You won!')),
      );
    }
  }

  void _undo() {
    if (_gameService.undoStackSize > 0) {
      _gameService.undo();
      setState(() {});
    }
  }

  void _showHint() {
    final gameState = _gameService.gameState;
    final hints = HintService().findHints(gameState);
    if (hints.isNotEmpty) {
      _currentHint = hints.first;
      setState(() {});
      // Clear hint after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _currentHint = null;
        });
      });
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          options: _gameService.options,
          onOptionsChanged: (newOptions) {
            _gameService.updateOptions(newOptions);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solitaire'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score display
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScoreDisplayWidget(
              score: _gameService.score,
              showTimer: _gameService.options.timedMode,
            ),
          ),
          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ControlButtonsWidget(
              onNewGame: _startNewGame,
              onUndo: _undo,
              onHint: _showHint,
              undoEnabled: _gameService.undoStackSize > 0,
            ),
          ),
          // Game board
          Expanded(
            child: BoardWidget(
              gameState: _gameService.gameState,
              onStockTap: _drawCard,
              onDropOnFoundation: _dropOnFoundation,
              onDropOnTableau: _dropOnTableau,
              hint: _currentHint,
            ),
          ),
        ],
      ),
    );
  }
}
