import 'package:flutter/material.dart';

/// A widget that displays control buttons for the game.
class ControlButtonsWidget extends StatelessWidget {
  /// Callback when the New Game button is tapped.
  final VoidCallback onNewGame;

  /// Callback when the Undo button is tapped.
  final VoidCallback onUndo;

  /// Callback when the Hint button is tapped.
  final VoidCallback onHint;

  /// Whether the undo button should be enabled.
  final bool undoEnabled;

  const ControlButtonsWidget({
    super.key,
    required this.onNewGame,
    required this.onUndo,
    required this.onHint,
    this.undoEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.refresh,
          label: 'New Game',
          onTap: onNewGame,
        ),
        const SizedBox(width: 12),
        _ControlButton(
          icon: Icons.undo,
          label: 'Undo',
          onTap: onUndo,
          enabled: undoEnabled,
        ),
        const SizedBox(width: 12),
        _ControlButton(
          icon: Icons.lightbulb,
          label: 'Hint',
          onTap: onHint,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onTap : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
