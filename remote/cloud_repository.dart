
abstract class CloudRepository {
  CloudRepository._();

  static CloudRepository get instance =>
      _CloudRepositoryAdapter.instance;

  Future<void> initialize();

  Future<Map<String, dynamic>?> getProfile(
    String userId,
  );

  Future<List<Map<String, dynamic>>>
      getConnectedPatients(
    String caregiverId,
  );

  Future<void> createConnection({
    required String caregiverId,
    required String patientId,
  });

  Future<void> acceptConnection(
    String connectionId,
  );

  Future<void> saveGameSession(
    Map<String, dynamic> data,
  );

  Future<void> saveRudasAssessment(
    Map<String, dynamic> data,
  );

  Future<void> saveTask(
    Map<String, dynamic> data,
  );

  Future<void> saveReminder(
    Map<String, dynamic> data,
  );

  Future<void> saveMemoryStory(
    Map<String, dynamic> data,
  );

  Future<void> saveMemoryPerson(
    Map<String, dynamic> data,
  );

  Future<void> saveMood(
    Map<String, dynamic> data,
  );

  Future<void> saveStoryRecall(
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>>
      pullPatientData(
    String patientId,
  );
}

class _CloudRepositoryAdapter
    implements CloudRepository {
  _CloudRepositoryAdapter._();

  static final _CloudRepositoryAdapter
      instance =
      _CloudRepositoryAdapter._();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<Map<String, dynamic>?> getProfile(
    String userId,
  ) async {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>>
      getConnectedPatients(
    String caregiverId,
  ) async {
    return const [];
  }

  @override
  Future<void> createConnection({
    required String caregiverId,
    required String patientId,
  }) async {}

  @override
  Future<void> acceptConnection(
    String connectionId,
  ) async {}

  @override
  Future<void> saveGameSession(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> saveRudasAssessment(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> saveTask(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> saveReminder(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> saveMemoryStory(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> saveMemoryPerson(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> saveMood(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> saveStoryRecall(
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<Map<String, dynamic>>
      pullPatientData(
    String patientId,
  ) async {
    return {
      'patient_id': patientId,
      'game_sessions': [],
      'rudas_assessments': [],
      'tasks': [],
      'reminders': [],
      'memory_stories': [],
      'memory_people': [],
      'mood_entries': [],
      'story_recall_events': [],
    };
  }
}
