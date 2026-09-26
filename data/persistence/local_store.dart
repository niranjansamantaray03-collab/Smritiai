
import 'persistence_record.dart';

abstract class LocalStore {
  Future<void> initialize();

  Future<void> put(
    PersistenceRecord record,
  );

  Future<PersistenceRecord?> get(
    String collection,
    String id,
  );

  Future<List<PersistenceRecord>> getCollection(
    String collection,
  );

  Future<void> delete(
    String collection,
    String id,
  );

  Future<void> clearCollection(
    String collection,
  );
}
