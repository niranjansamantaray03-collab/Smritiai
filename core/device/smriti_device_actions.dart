
import 'dart:io';

import '../../features/memory/services/native_memory_media_controller.dart';
import '../../features/notifications/native_notification_controller.dart';
import '../../features/patient/welcome_music_controller.dart';
import '../../features/voice/services/native_voice_controller.dart';
import '../../features/voice/voice_locale.dart';

class SmritiDeviceActions {
  SmritiDeviceActions._();

  static final SmritiDeviceActions instance =
      SmritiDeviceActions._();

  final _media =
      NativeMemoryMediaController.instance;

  final _voice =
      NativeVoiceController.instance;

  final _notifications =
      NativeNotificationController.instance;

  final _music =
      WelcomeMusicController.instance;

  Future<File?> chooseMemoryPhoto() {
    return _media.selectPhoto();
  }

  Future<File?> captureMemoryPhoto() {
    return _media.capturePhoto();
  }

  Future<void> speak(
    String text, {
    VoiceLocale locale = VoiceLocale.english,
  }) {
    return _voice.speak(
      text,
      locale: locale,
    );
  }

  Future<String?> listen({
    VoiceLocale locale = VoiceLocale.english,
  }) {
    return _voice.listen(
      locale: locale,
    );
  }

  Future<void> startWelcomeMusic() {
    return _music.play();
  }

  Future<void> stopWelcomeMusic() {
    return _music.stop();
  }

  Future<void> requestNotificationPermission() {
    return _notifications.requestPermission();
  }

  Future<void> showReminder({
    required int id,
    required String title,
    required String body,
  }) {
    return _notifications.showNow(
      id: id,
      title: title,
      body: body,
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) {
    return _notifications.scheduleOnce(
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
    );
  }

  Future<void> cancelReminder(int id) {
    return _notifications.cancel(id);
  }
}
