
import 'backend_config.dart';

class ProductionBackend {
  ProductionBackend._();

  static final ProductionBackend instance =
      ProductionBackend._();

  bool _initialized = false;

  bool get initialized => _initialized;

  bool get configured =>
      BackendConfig.isConfigured;

  Future<void> initialize() async {
    if (_initialized) return;

    if (!configured) {
      // Offline mode is allowed.
      _initialized = true;
      return;
    }

    // Supabase runtime initialization is performed
    // by the application bootstrap layer.
    //
    // Never place a service-role key, database password,
    // secret key, or admin credential inside this class
    // or inside the Android application.

    _initialized = true;
  }
}
