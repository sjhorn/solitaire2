import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/high_score.dart';
import 'package:solitaire/src/domain/high_score_service.dart';

/// A screen that displays high scores for different game configurations.
class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  final HighScoreService _highScoreService = HighScoreService();
  Map<String, List<HighScore>> _allScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() => _isLoading = true);
    _allScores = await _highScoreService.getAllHighScores();
    setState(() => _isLoading = false);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Scores'),
        actions: [
          Semantics(
            label: 'Refresh high scores',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadScores,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allScores.isEmpty
              ? Semantics(
                  label: 'No high scores yet. Play games to earn scores.',
                  child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No high scores yet!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Play games to earn scores.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
              : Semantics(
                  label: 'High scores by configuration',
                  child: DefaultTabController(
                    length: _allScores.length,
                    child: Column(
                      children: [
                        // Tab bar for configurations
                        Semantics(
                          label: 'Game configuration tabs',
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            child: TabBar(
                              isScrollable: true,
                              tabs: _allScores.keys.map((config) {
                                return Tab(text: _formatConfiguration(config));
                              }).toList(),
                            ),
                          ),
                        ),
                      // Tab views for each configuration
                      Expanded(
                        child: TabBarView(
                          children: _allScores.keys.map((config) {
                            final scores = _allScores[config]!;
                            return _buildScoreList(scores, config);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  String _formatConfiguration(String config) {
    // Format: 'vegas-draw3' -> 'Vegas (Draw 3)'
    final parts = config.split('-');
    final mode = parts[0].substring(0, 1).toUpperCase() + parts[0].substring(1);
    if (parts.length > 1 && parts[1].startsWith('draw')) {
      final drawCount = parts[1].substring(4);
      return '$mode (Draw $drawCount)';
    }
    return mode;
  }

  Widget _buildScoreList(List<HighScore> scores, String configuration) {
    if (scores.isEmpty) {
      return Semantics(
        label: 'No scores for this configuration',
        child: const Center(
          child: Text('No scores for this configuration'),
        ),
      );
    }

    return Semantics(
      label: 'High scores for ${_formatConfiguration(configuration)}',
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: scores.length,
        itemBuilder: (context, index) {
          final score = scores[index];
          final isTopThree = index < 3;
          final rank = index + 1;

          return Semantics(
            label: 'Rank ${isTopThree ? rank : '#$rank'}: Score ${score.score}, Moves ${score.moves}, Time ${_formatDuration(score.duration)}',
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: _buildRankBadge(index, isTopThree),
                title: Text(
                  'Score: ${score.score}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Moves: ${score.moves}'),
                    Text('Time: ${_formatDuration(score.duration)}'),
                    Text(
                      'Played: ${_formatDate(score.playedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: isTopThree
                    ? Icon(
                        index == 0
                            ? Icons.emoji_events
                            : (index == 1
                                ? Icons.local_fire_department
                                : Icons.local_fire_department_outlined),
                        color: index == 0
                            ? const Color(0xFFFFD700) // Gold
                            : (index == 1
                                ? Colors.orange
                                : const Color(0xFF8B4513)), // Brown
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankBadge(int index, bool isTopThree) {
    if (!isTopThree) {
      return Text(
        '#${index + 1}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: index == 0
            ? const Color(0xFFFFD700) // Gold
            : (index == 1 ? Colors.orange : const Color(0xFF8B4513)), // Brown
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
