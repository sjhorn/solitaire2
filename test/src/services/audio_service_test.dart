import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/services/audio_service.dart';

void main() {
  group('AudioService', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
    });

    tearDown(() async {
      await audioService.dispose();
    });

    group('Sound playback', () {
      test('SoundEffect enum has all required sounds', () {
        expect(SoundEffect.values, hasLength(6));
        expect(SoundEffect.values, contains(SoundEffect.cardSlide));
        expect(SoundEffect.values, contains(SoundEffect.cardFlip));
        expect(SoundEffect.values, contains(SoundEffect.cardPlace));
        expect(SoundEffect.values, contains(SoundEffect.stockTap));
        expect(SoundEffect.values, contains(SoundEffect.moveRejected));
        expect(SoundEffect.values, contains(SoundEffect.winFanfare));
      });
    });
  });

  group('MockAudioService', () {
    late MockAudioService mockService;

    setUp(() {
      mockService = MockAudioService();
    });

    test('tracks played sounds', () {
      mockService.playCardSlide();
      mockService.playCardFlip();
      mockService.playCardPlace();

      expect(mockService.playedSounds, [
        SoundEffect.cardSlide,
        SoundEffect.cardFlip,
        SoundEffect.cardPlace,
      ]);
    });

    test('does not play sounds when disabled', () async {
      mockService.isSoundEnabled = false;

      await mockService.playCardSlide();
      await mockService.playCardFlip();

      expect(mockService.playedSounds, isEmpty);
    });

    test('tracks haptic feedback', () async {
      await mockService.triggerHaptic();
      await mockService.triggerHeavyHaptic();
      await mockService.triggerSelectionHaptic();

      expect(mockService.triggeredHaptics, [
        'lightImpact',
        'heavyImpact',
        'selectionClick',
      ]);
    });

    test('has correct initial state', () {
      expect(mockService.isSoundEnabled, isTrue);
      expect(mockService.playedSounds, isEmpty);
      expect(mockService.triggeredHaptics, isEmpty);
    });

    test('reset clears all tracked data', () async {
      await mockService.playCardSlide();
      await mockService.triggerHaptic();
      mockService.reset();

      expect(mockService.playedSounds, isEmpty);
      expect(mockService.triggeredHaptics, isEmpty);
    });

    test('playCardSlide records the sound', () async {
      await mockService.playCardSlide();

      expect(mockService.playedSounds, [SoundEffect.cardSlide]);
    });

    test('playCardFlip records the sound', () async {
      await mockService.playCardFlip();

      expect(mockService.playedSounds, [SoundEffect.cardFlip]);
    });

    test('playCardPlace records the sound', () async {
      await mockService.playCardPlace();

      expect(mockService.playedSounds, [SoundEffect.cardPlace]);
    });

    test('playStockTap records the sound', () async {
      await mockService.playStockTap();

      expect(mockService.playedSounds, [SoundEffect.stockTap]);
    });

    test('playMoveRejected records the sound', () async {
      await mockService.playMoveRejected();

      expect(mockService.playedSounds, [SoundEffect.moveRejected]);
    });

    test('playWinFanfare records the sound', () async {
      await mockService.playWinFanfare();

      expect(mockService.playedSounds, [SoundEffect.winFanfare]);
    });

    test('can re-enable sound after disabling', () async {
      mockService.isSoundEnabled = false;
      await mockService.playCardSlide();
      expect(mockService.playedSounds, isEmpty);

      mockService.isSoundEnabled = true;
      await mockService.playCardSlide();
      expect(mockService.playedSounds, [SoundEffect.cardSlide]);
    });
  });
}
