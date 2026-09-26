/// Canonical database table names used by SmritiAI.
///
/// Keeping names centralized prevents different features from
/// accidentally using different patient identifiers or table names.
class DataContract {
  static const profiles = 'profiles';
  static const connections = 'caregiver_patient_connections';
  static const rudasAssessments = 'rudas_assessments';
  static const gameSessions = 'game_sessions';
  static const tasks = 'tasks';
  static const reminders = 'reminders';
  static const memoryStories = 'memory_stories';
  static const memoryPhotos = 'memory_photos';
  static const moodEntries = 'mood_entries';
  static const storyRecallEvents = 'story_recall_events';
  static const rudasCheckpoints = 'rudas_checkpoints';

  static const memoryPhotoBucket = 'memory-photos';
  static const memoryAudioBucket = 'memory-audio';
}
