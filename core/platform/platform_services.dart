
class PlatformServices {
  PlatformServices._();

  static bool notificationsReady = false;
  static bool mediaReady = false;
  static bool voiceReady = false;
  static bool speechReady = false;

  static Future<void> initialize() async {
    // Native adapters are enabled during the Android
    // dependency/build stage.
    //
    // Keeping these flags explicit prevents the UI from
    // assuming that browser/demo services are native.
  }
}
