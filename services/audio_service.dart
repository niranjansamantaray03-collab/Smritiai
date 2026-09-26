
import 'package:audioplayers/audioplayers.dart';

/// Central audio controller for SmritiAI.
///
/// Audio is intentionally gentle and optional. The bundled welcome track
/// is an original nostalgic instrumental, not a copyrighted 90s recording.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  bool musicEnabled = true;
  bool effectsEnabled = true;

  Future<void> initialize() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.20);
    await _effectPlayer.setVolume(0.22);
  }

  Future<void> playWelcomeMusic() async {
    if (!musicEnabled) return;

    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(
      AssetSource('audio/welcome_nostalgia.wav'),
      volume: 0.20,
    );
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> playGameStart() async {
    if (!effectsEnabled) return;
    await _effectPlayer.play(
      AssetSource('audio/game_start.wav'),
      volume: 0.18,
    );
  }

  Future<void> playCorrect() async {
    if (!effectsEnabled) return;
    await _effectPlayer.play(
      AssetSource('audio/game_correct.wav'),
      volume: 0.16,
    );
  }

  Future<void> playWrong() async {
    if (!effectsEnabled) return;
    await _effectPlayer.play(
      AssetSource('audio/game_wrong.wav'),
      volume: 0.08,
    );
  }

  Future<void> playGameComplete() async {
    if (!effectsEnabled) return;
    await _effectPlayer.play(
      AssetSource('audio/game_complete.wav'),
      volume: 0.18,
    );
  }

  Future<void> playTap() async {
    if (!effectsEnabled) return;
    await _effectPlayer.play(
      AssetSource('audio/soft_tap.wav'),
      volume: 0.08,
    );
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _effectPlayer.dispose();
  }
}
