import 'package:solitaire/src/domain/game_score.dart';
import 'package:solitaire/src/domain/game_state.dart';
import 'package:solitaire/src/domain/game_state_options.dart';

/// A service that manages the game state, scoring, undo history, and options.
///
/// This class provides the complete game controller for solitaire, combining
/// the pure game logic from [GameState] with scoring, undo support, and settings.
class GameService {
  GameState _gameState;
  GameScore _score;
  GameStateOptions _options;
  final List<GameState> _undoStack;

  GameService({
    required GameState gameState,
    required GameScore score,
    required GameStateOptions options,
  })  : _gameState = gameState,
        _score = score,
        _options = options,
        _undoStack = [];

  /// Creates a new game with default options.
  factory GameService.newGame() {
    return GameService(
      gameState: GameState.initial(),
      score: GameScore.start(),
      options: const GameStateOptions(),
    );
  }

  GameState get gameState => _gameState;
  GameScore get score => _score;
  GameStateOptions get options => _options;
  int get undoStackSize => _undoStack.length;

  /// Updates the game options.
  GameService updateOptions(GameStateOptions newOptions) {
    _options = newOptions;
    return this;
  }

  /// Draws a card from stock to waste.
  GameService drawCard() {
    _saveUndo();
    _gameState = _gameState.drawFromStock();
    _score = _score.addMove(options: _options, moveType: MoveType.draw);
    return this;
  }

  /// Moves waste card to foundation.
  GameService? moveWasteToFoundation(int foundationIndex) {
    final result = _gameState.moveWasteToFoundation(foundationIndex);
    if (result == null) return null;

    _saveUndo();
    _gameState = result;
    _score = _score.addMove(options: _options, moveType: MoveType.wasteToFoundation);
    return this;
  }

  /// Moves tableau card to foundation.
  GameService? moveTableauToFoundation(int tableauIndex, int foundationIndex) {
    final result = _gameState.moveTableauToFoundation(tableauIndex, foundationIndex);
    if (result == null) return null;

    _saveUndo();
    _gameState = result;
    _score = _score.addMove(options: _options, moveType: MoveType.tableauToFoundation);
    return this;
  }

  /// Moves waste card to tableau.
  GameService? moveWasteToTableau(int tableauIndex) {
    final result = _gameState.moveWasteToTableau(tableauIndex);
    if (result == null) return null;

    _saveUndo();
    _gameState = result;
    _score = _score.addMove(options: _options, moveType: MoveType.wasteToTableau);
    return this;
  }

  /// Moves foundation card to tableau.
  GameService? moveFoundationToTableau(int foundationIndex, int tableauIndex) {
    final result = _gameState.moveFoundationToTableau(foundationIndex, tableauIndex);
    if (result == null) return null;

    _saveUndo();
    _gameState = result;
    _score = _score.addMove(options: _options, moveType: MoveType.foundationToTableau);
    return this;
  }

  /// Moves cards between tableau piles.
  GameService? moveTableauToTableau(int fromIndex, int toIndex) {
    final result = _gameState.moveTableauToTableau(fromIndex, toIndex);
    if (result == null) return null;

    _saveUndo();
    _gameState = result;
    _score = _score.addMove(options: _options, moveType: MoveType.tableauToTableau);
    return this;
  }

  /// Flips a tableau card.
  GameService? flipTableauCard(int tableauIndex) {
    final result = _gameState.flipTableauCard(tableauIndex);
    if (result == null) return null;

    _saveUndo();
    _gameState = result;
    _score = _score.addMove(options: _options, moveType: MoveType.flipTableau);
    return this;
  }

  /// Undoes the last move.
  GameService undo() {
    if (_undoStack.isEmpty) return this;

    _gameState = _undoStack.last;
    _undoStack.removeLast();
    _score = _score.addMove(options: _options, moveType: MoveType.draw, isUndo: true);
    return this;
  }

  void _saveUndo() {
    // Save a copy of the current state for undo
    // Note: This is a shallow copy; for full undo support we'd need deep copies
    _undoStack.add(_gameState);
  }

  /// Updates the elapsed time.
  GameService updateElapsedTime() {
    _score = _score.updateElapsedTime();
    return this;
  }

  /// Marks the game as won.
  GameService markWon() {
    _score = _score.markWon();
    return this;
  }

  /// Checks if the game is won.
  bool get isWon => _gameState.isWon;
}
