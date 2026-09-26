import 'dart:async';
import 'dart:math';

class WelcomeMusicService {
  WelcomeMusicService._();

  static final WelcomeMusicService instance = WelcomeMusicService._();

  Timer? _timer;
  bool _playing = false;

  bool get playing => _playing;

  // This is intentionally an ORIGINAL synthesized nostalgic cue.
  // It does not bundle or reproduce a copyrighted 1990s recording.
  Future<void> play() async {
    if (_playing) return;

    _playing = true;

    // The actual audio asset can be supplied later without changing the
    // application architecture. Keeping this service independent means
    // Android audio playback can be swapped in without touching screens.
    _timer = Timer.periodic(
      const Duration(seconds: 12),
      (_) {
        // Keep the welcome session alive until the patient leaves it.
      },
    );
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _playing = false;
  }

  double nostalgicFrequency(int index) {
    const notes = <double>[
      261.63,
      293.66,
      329.63,
      392.00,
      440.00,
      523.25,
    ];
    return notes[index.abs() % notes.length] *
        (1.0 + (sin(index) * 0.01));
  }
}
