
import 'package:uuid/uuid.dart';

import '../../features/games/models/game_history_entry.dart';
import '../../features/memory/models/memory_person.dart';
import '../../features/memory/models/memory_story.dart';
import '../../features/memory/models/story_recall_event.dart';
import '../../features/mood/mood_entry.dart';
import '../../features/rudas/models/rudas_assessment.dart';
import '../../features/tasks/models/caregiver_task.dart';
import '../../features/notifications/reminder.dart';

import 'feature_collections.dart';
import 'feature_persistence_gateway.dart';

/// One entry point used by feature services when they create/update data.
///
/// Local persistence always happens before cloud synchronization.
class FeatureWriteService {
  FeatureWriteService._();

  static final FeatureWriteService instance = FeatureWriteService._();

  final FeaturePersistenceGateway _gateway =
      FeaturePersistenceGateway.instance;

  final Uuid _uuid = const Uuid();

  String _id(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      return value;
    }
    return _uuid.v4();
  }

  Future<void> saveGame(GameHistoryEntry entry) async {
    final id = _id(entry.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.gameSessions,
      recordId: id,
      patientId: entry.patientId,
      data: entry.toMap(),
    );
  }

  Future<void> saveRudas(RudasAssessment assessment) async {
    final id = _id(assessment.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.rudasAssessments,
      recordId: id,
      patientId: assessment.patientId,
      data: assessment.toMap(),
    );
  }

  Future<void> saveTask(CaregiverTask task) async {
    final id = _id(task.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.tasks,
      recordId: id,
      patientId: task.patientId,
      data: task.toMap(),
    );
  }

  Future<void> saveReminder(SmritiReminder reminder) async {
    final id = _id(reminder.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.reminders,
      recordId: id,
      patientId: reminder.patientId,
      data: reminder.toMap(),
    );
  }

  Future<void> saveStory(MemoryStory story) async {
    final id = _id(story.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.memoryStories,
      recordId: id,
      patientId: story.patientId,
      data: story.toMap(),
    );
  }

  Future<void> savePerson(MemoryPerson person) async {
    final id = _id(person.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.memoryPeople,
      recordId: id,
      patientId: person.patientId,
      data: person.toMap(),
    );
  }

  Future<void> saveMood(MoodEntry entry) async {
    final id = _id(entry.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.moodEntries,
      recordId: id,
      patientId: entry.patientId,
      data: entry.toMap(),
    );
  }

  Future<void> saveStoryRecall(StoryRecallEvent event) async {
    final id = _id(event.id);

    await _gateway.saveRecord(
      collection: FeatureCollections.storyRecallEvents,
      recordId: id,
      patientId: event.patientId,
      data: event.toMap(),
    );
  }

  Future<void> delete({
    required String collection,
    required String id,
    required String patientId,
  }) {
    return _gateway.deleteRecord(
      collection: collection,
      recordId: id,
      patientId: patientId,
    );
  }
}
