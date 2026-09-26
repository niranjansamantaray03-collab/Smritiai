import '../../services/native_notification_service.dart';
import '../../features/voice/services/native_voice_service.dart';
import '../../features/voice/services/native_speech_service.dart';
import '../../features/voice/services/native_audio_recorder.dart';
import '../../features/memory/services/native_media_service.dart';
import '../../services/welcome_music_service.dart';

class SmritiNativeServices {
  SmritiNativeServices._();

  static Future<void> initialize() async {
    await NativeNotificationService.instance.initialize();
    await NativeVoiceService.instance.initialize();
    await WelcomeMusicService.instance.play();
  }

  static final notifications = NativeNotificationService.instance;
  static final voice = NativeVoiceService.instance;
  static final speech = NativeSpeechService.instance;
  static final recorder = NativeAudioRecorder.instance;
  static final media = NativeMediaService.instance;
  static final music = WelcomeMusicService.instance;
}
