
import '../../data/persistence/persistence_manager.dart';
import '../../data/sync/sync_manager.dart';

class AppInitializer {
  AppInitializer._();

  static final AppInitializer instance =
      AppInitializer._();

  bool _done = false;

  bool get initialized => _done;

  Future<void> initialize() async {
    if (_done) return;

    await PersistenceManager.instance
        .initialize();

    await SyncManager.instance
        .initialize();

    _done = true;
  }
}
