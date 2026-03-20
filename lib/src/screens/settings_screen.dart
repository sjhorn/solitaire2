import 'package:flutter/material.dart';
import 'package:solitaire/src/domain/game_state_options.dart';

/// A screen that displays and allows modification of game settings.
class SettingsScreen extends StatefulWidget {
  /// The current game options.
  final GameStateOptions options;

  /// Callback when the options are changed.
  final Function(GameStateOptions newOptions) onOptionsChanged;

  const SettingsScreen({
    super.key,
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameStateOptions _localOptions;

  @override
  void initState() {
    super.initState();
    _localOptions = widget.options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Game Settings',
            children: [
              _DrawModeSection(
                currentMode: _localOptions.drawMode,
                onChanged: (mode) {
                  setState(() {
                    _localOptions = _localOptions.copyWith(drawMode: mode);
                  });
                  widget.onOptionsChanged(_localOptions);
                },
              ),
              const Divider(height: 1),
              _ScoringModeSection(
                currentMode: _localOptions.scoringMode,
                onChanged: (mode) {
                  setState(() {
                    _localOptions = _localOptions.copyWith(scoringMode: mode);
                  });
                  widget.onOptionsChanged(_localOptions);
                },
              ),
              const Divider(height: 1),
              _TimedModeSection(
                isEnabled: _localOptions.timedMode,
                onChanged: (enabled) {
                  setState(() {
                    _localOptions = _localOptions.copyWith(timedMode: enabled);
                  });
                  widget.onOptionsChanged(_localOptions);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Appearance',
            children: [
              _CardBackSection(
                currentDesign: _localOptions.cardBackDesign,
                onChanged: (design) {
                  setState(() {
                    _localOptions = _localOptions.copyWith(cardBackDesign: design);
                  });
                  widget.onOptionsChanged(_localOptions);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _InfoCard(
              title: 'Scoring Info',
              content: _localOptions.scoringMode == ScoringMode.vegas
                  ? 'Vegas Mode: +10 points for waste→tableau and tableau→foundation moves. -2 points per 10 seconds in timed mode. -100 points for undo.'
                  : 'Classic Mode: No scoring. Just enjoy the game!',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _DrawModeSection extends StatelessWidget {
  final DrawMode currentMode;
  final Function(DrawMode) onChanged;

  const _DrawModeSection({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RadioOption(
          title: const Text('Draw One'),
          subtitle: const Text('Draw one card at a time'),
          isSelected: currentMode == DrawMode.drawOne,
          onTap: () => onChanged(DrawMode.drawOne),
        ),
        _RadioOption(
          title: const Text('Draw Three'),
          subtitle: const Text('Draw three cards at a time'),
          isSelected: currentMode == DrawMode.drawThree,
          onTap: () => onChanged(DrawMode.drawThree),
        ),
      ],
    );
  }
}

class _ScoringModeSection extends StatelessWidget {
  final ScoringMode currentMode;
  final Function(ScoringMode) onChanged;

  const _ScoringModeSection({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RadioOption(
          title: const Text('Classic'),
          subtitle: const Text('No scoring, just play'),
          isSelected: currentMode == ScoringMode.classic,
          onTap: () => onChanged(ScoringMode.classic),
        ),
        _RadioOption(
          title: const Text('Vegas'),
          subtitle: const Text('Points for moves, penalties for time'),
          isSelected: currentMode == ScoringMode.vegas,
          onTap: () => onChanged(ScoringMode.vegas),
        ),
      ],
    );
  }
}

class _TimedModeSection extends StatelessWidget {
  final bool isEnabled;
  final Function(bool) onChanged;

  const _TimedModeSection({
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Timed Mode'),
      subtitle: const Text('Enable time-based scoring'),
      value: isEnabled,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _CardBackSection extends StatelessWidget {
  final CardBackDesign currentDesign;
  final Function(CardBackDesign) onChanged;

  const _CardBackSection({
    required this.currentDesign,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RadioOption(
          title: const Text('Classic Blue'),
          isSelected: currentDesign == CardBackDesign.classic,
          onTap: () => onChanged(CardBackDesign.classic),
        ),
        _RadioOption(
          title: const Text('Blue'),
          isSelected: currentDesign == CardBackDesign.blue,
          onTap: () => onChanged(CardBackDesign.blue),
        ),
        _RadioOption(
          title: const Text('Red'),
          isSelected: currentDesign == CardBackDesign.red,
          onTap: () => onChanged(CardBackDesign.red),
        ),
        _RadioOption(
          title: const Text('Green'),
          isSelected: currentDesign == CardBackDesign.green,
          onTap: () => onChanged(CardBackDesign.green),
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    subtitle!,
                  ],
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
