
import 'local_store.dart';
import 'persistence_record.dart';

class MemoryLocalStore implements LocalStore {
  final Map<String, PersistenceRecord> _records =
      {};

  @override
  Future<void> initialize() async {}

  String _key(
    String collection,
    String id,
  ) =>
      '$collection::$id';

  @override
  Future<void> put(
    PersistenceRecord record,
  ) async {
    _records[
        _key(record.collection, record.id)] =
        record;
  }

  @override
  Future<PersistenceRecord?> get(
    String collection,
    String id,
  ) async {
    return _records[_key(collection, id)];
  }

  @override
  Future<List<PersistenceRecord>>
      getCollection(
    String collection,
  ) async {
    return _records.values
        .where(
          (record) =>
              record.collection ==
              collection,
        )
        .toList();
  }

  @override
  Future<void> delete(
    String collection,
    String id,
  ) async {
    _records.remove(
      _key(collection, id),
    );
  }

  @override
  Future<void> clearCollection(
    String collection,
  ) async {
    _records.removeWhere(
      (_, record) =>
          record.collection ==
          collection,
    );
  }
}
