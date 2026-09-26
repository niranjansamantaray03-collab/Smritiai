
import 'local_store.dart';
import 'memory_local_store.dart';

class PersistenceManager {
  PersistenceManager._();

  static final PersistenceManager instance =
      PersistenceManager._();

  LocalStore _store = MemoryLocalStore();
  bool _initialized = false;

  Future<void> initialize({
    LocalStore? store,
  }) async {
    if (_initialized) return;

    if (store != null) {
      _store = store;
    }

    await _store.initialize();
    _initialized = true;
  }

  Future<void> save(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await initialize();

    await _store.put(
      PersistenceRecord(
        collection: collection,
        id: id,
        data: Map<String, dynamic>.from(data),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<Map<String, dynamic>?> get(
    String collection,
    String id,
  ) async {
    await initialize();

    final record =
        await _store.get(
      collection,
      id,
    );

    return record == null
        ? null
        : Map<String, dynamic>.from(
            record.data,
          );
  }

  Future<List<Map<String, dynamic>>>
      getAll(
    String collection,
  ) async {
    await initialize();

    final records =
        await _store.getCollection(
      collection,
    );

    return records
        .map(
          (record) =>
              Map<String, dynamic>.from(
            record.data,
          ),
        )
        .toList();
  }

  Future<void> delete(
    String collection,
    String id,
  ) async {
    await initialize();

    await _store.delete(
      collection,
      id,
    );
  }

  Future<void> clear(
    String collection,
  ) async {
    await initialize();

    await _store.clearCollection(
      collection,
    );
  }
}
