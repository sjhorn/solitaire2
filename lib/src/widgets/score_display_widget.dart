import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_score.dart';

/// A widget that displays the current game score, moves, and elapsed time.
class ScoreDisplayWidget extends StatelessWidget {
  /// The current game score.
  final GameScore score;

  /// Whether to show the timer (only shown in timed mode).
  final bool showTimer;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    this.showTimer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScoreItem(
            label: 'Score',
            value: score.score.toString(),
          ),
          const SizedBox(width: 16),
          _ScoreItem(
            label: 'Moves',
            value: score.moves.toString(),
          ),
          if (showTimer) ...[
            const SizedBox(width: 16),
            _ScoreItem(
              label: 'Time',
              value: _formatDuration(score.elapsedDuration),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
