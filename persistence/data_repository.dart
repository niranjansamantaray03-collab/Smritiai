
import 'persistence_manager.dart';
import '../sync/sync_manager.dart';

class DataRepository {
  DataRepository._();

  static final DataRepository instance =
      DataRepository._();

  Future<void> savePatientRecord({
    required String collection,
    required String id,
    required String patientId,
    required Map<String, dynamic> data,
  }) async {
    final payload =
        Map<String, dynamic>.from(data);

    payload['patient_id'] = patientId;
    payload['updated_at'] =
        DateTime.now().toIso8601String();

    await PersistenceManager.instance.save(
      collection,
      id,
      payload,
    );

    SyncManager.instance.queueRecord(
      collection: collection,
      patientId: patientId,
      operation: 'upsert',
      data: payload,
    );
  }

  Future<Map<String, dynamic>?> get(
    String collection,
    String id,
  ) {
    return PersistenceManager.instance.get(
      collection,
      id,
    );
  }

  Future<List<Map<String, dynamic>>> getAll(
    String collection,
  ) {
    return PersistenceManager.instance.getAll(
      collection,
    );
  }

  Future<void> delete(
    String collection,
    String id,
  ) {
    return PersistenceManager.instance.delete(
      collection,
      id,
    );
  }
}
