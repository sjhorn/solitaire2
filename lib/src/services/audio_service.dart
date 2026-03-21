import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Enum representing available sound effects in the game.
enum SoundEffect {
  cardSlide,
  cardFlip,
  cardPlace,
  stockTap,
  moveRejected,
  winFanfare,
}

/// Service that manages sound effects and haptic feedback.
class AudioService {
  final AudioPlayer? _audioPlayer;
  bool _isSoundEnabled = true;

  AudioService({AudioPlayer? audioPlayer}) : _audioPlayer = audioPlayer;

  /// Sets whether sound is enabled.
  set isSoundEnabled(bool value) => _isSoundEnabled = value;

  bool get isSoundEnabled => _isSoundEnabled;

  /// Plays a sound effect if sound is enabled.
  Future<void> playSound(SoundEffect sound) async {
    if (!_isSoundEnabled) return;

    try {
      // Note: In a real implementation, you would load actual audio files
      // For now, this is a placeholder structure
      // await _audioPlayer?.play(AssetSource('sounds/${sound.name}.mp3'));
    } catch (e) {
      // Silently fail if sound cannot be played
    }
  }

  /// Plays the card slide sound.
  Future<void> playCardSlide() => playSound(SoundEffect.cardSlide);

  /// Plays the card flip sound.
  Future<void> playCardFlip() => playSound(SoundEffect.cardFlip);

  /// Plays the card place sound.
  Future<void> playCardPlace() => playSound(SoundEffect.cardPlace);

  /// Plays the stock tap sound.
  Future<void> playStockTap() => playSound(SoundEffect.stockTap);

  /// Plays the move rejected sound.
  Future<void> playMoveRejected() => playSound(SoundEffect.moveRejected);

  /// Plays the win fanfare sound.
  Future<void> playWinFanfare() => playSound(SoundEffect.winFanfare);

  /// Triggers haptic feedback.
  Future<void> triggerHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail if haptic feedback cannot be triggered
    }
  }

  /// Triggers heavy haptic feedback (for special events).
  Future<void> triggerHeavyHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently fail if haptic feedback cannot be triggered
    }
  }

  /// Triggers selection haptic feedback.
  Future<void> triggerSelectionHaptic() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silently fail if haptic feedback cannot be triggered
    }
  }

  /// Disposes of resources.
  Future<void> dispose() async {
    await _audioPlayer?.dispose();
  }
}

/// A mock audio service for testing purposes.
class MockAudioService {
  final List<SoundEffect> _playedSounds = [];
  final List<String> _triggeredHaptics = [];
  bool _isSoundEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;

  set isSoundEnabled(bool value) => _isSoundEnabled = value;

  List<SoundEffect> get playedSounds => List.unmodifiable(_playedSounds);
  List<String> get triggeredHaptics => List.unmodifiable(_triggeredHaptics);

  Future<void> playSound(SoundEffect sound) async {
    if (_isSoundEnabled) {
      _playedSounds.add(sound);
    }
  }

  Future<void> playCardSlide() => playSound(SoundEffect.cardSlide);

  Future<void> playCardFlip() => playSound(SoundEffect.cardFlip);

  Future<void> playCardPlace() => playSound(SoundEffect.cardPlace);

  Future<void> playStockTap() => playSound(SoundEffect.stockTap);

  Future<void> playMoveRejected() => playSound(SoundEffect.moveRejected);

  Future<void> playWinFanfare() => playSound(SoundEffect.winFanfare);

  Future<void> triggerHaptic() async {
    _triggeredHaptics.add('lightImpact');
  }

  Future<void> triggerHeavyHaptic() async {
    _triggeredHaptics.add('heavyImpact');
  }

  Future<void> triggerSelectionHaptic() async {
    _triggeredHaptics.add('selectionClick');
  }

  Future<void> dispose() async {}

  void reset() {
    _playedSounds.clear();
    _triggeredHaptics.clear();
  }
}
