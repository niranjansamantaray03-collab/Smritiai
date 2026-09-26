
import 'sync_manager.dart';

class SyncController {
  SyncController._();

  static final SyncController instance =
      SyncController._();

  bool online = true;

  Future<void> initialize() async {
    await SyncManager.instance
        .initialize();
  }

  Future<void> onConnectivityChanged(
    bool connected,
  ) async {
    online = connected;

    if (connected) {
      await SyncManager.instance
          .process();
    }
  }
}
