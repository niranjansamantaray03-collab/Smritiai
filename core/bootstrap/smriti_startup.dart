import '../../services/audio_service.dart';

import '../../data/persistence/feature_persistence_gateway.dart';
import '../../data/sync/app_sync_controller.dart';

class SmritiStartup {
  SmritiStartup._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    await AudioService.instance.initialize();
    if (_initialized) return;

    await FeaturePersistenceGateway.instance.initialize();
    await AppSyncController.instance.start();

    _initialized = true;
  }
}
