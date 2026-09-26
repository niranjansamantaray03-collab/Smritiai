
import 'feature_collections.dart';
import 'feature_persistence_gateway.dart';

/// Reads the local durable cache when the cloud is unavailable.
class FeatureReadService {
  FeatureReadService._();

  static final FeatureReadService instance = FeatureReadService._();

  final FeaturePersistenceGateway _gateway =
      FeaturePersistenceGateway.instance;

  Future<List<Map<String, dynamic>>> games(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.gameSessions,
      patientId: patientId,
    );
  }

  Future<List<Map<String, dynamic>>> rudas(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.rudasAssessments,
      patientId: patientId,
    );
  }

  Future<List<Map<String, dynamic>>> tasks(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.tasks,
      patientId: patientId,
    );
  }

  Future<List<Map<String, dynamic>>> reminders(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.reminders,
      patientId: patientId,
    );
  }

  Future<List<Map<String, dynamic>>> stories(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.memoryStories,
      patientId: patientId,
    );
  }

  Future<List<Map<String, dynamic>>> people(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.memoryPeople,
      patientId: patientId,
    );
  }

  Future<List<Map<String, dynamic>>> mood(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.moodEntries,
      patientId: patientId,
    );
  }

  Future<List<Map<String, dynamic>>> storyRecall(String patientId) {
    return _gateway.readCollection(
      collection: FeatureCollections.storyRecallEvents,
      patientId: patientId,
    );
  }
}
