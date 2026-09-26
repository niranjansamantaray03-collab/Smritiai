
import 'backend_config.dart';

class AppMode {
  AppMode._();

  static bool get cloudEnabled =>
      BackendConfig.isConfigured;

  static bool get offlineEnabled =>
      !BackendConfig.isConfigured;

  static String get label =>
      cloudEnabled
          ? 'Cloud sync enabled'
          : 'Offline mode';
}
