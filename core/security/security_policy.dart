
class SecurityPolicy {
  SecurityPolicy._();

  static const String appId = 'com.smritiai.app';

  static const int maxSyncAttempts = 8;

  static const Duration syncRetryBase =
      Duration(seconds: 5);

  static const Duration sessionTimeout =
      Duration(hours: 12);

  static const int maxMemoryTitleLength = 120;
  static const int maxMemoryDescriptionLength = 2000;

  static const int maxTaskTitleLength = 160;
  static const int maxTaskDescriptionLength = 2000;

  static const int maxMoodNoteLength = 1000;

  static const int maxRudasNotesLength = 4000;

  static bool validPatientId(String? id) {
    if (id == null || id.trim().isEmpty) {
      return false;
    }

    return id != 'current_patient';
  }

  static bool validRecordId(String? id) {
    if (id == null || id.trim().isEmpty) {
      return false;
    }

    return id.length <= 128;
  }

  static String cleanText(
    String value, {
    int maxLength = 1000,
  }) {
    final normalized =
        value.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalized.length <= maxLength) {
      return normalized;
    }

    return normalized.substring(0, maxLength);
  }
}
