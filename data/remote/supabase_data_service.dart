
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend/production_backend.dart';

class SupabaseDataService {
  SupabaseDataService._();

  static final SupabaseDataService instance = SupabaseDataService._();

  SupabaseClient? get _db => ProductionBackend.instance.client;

  bool get available => _db != null;

  String? get userId => _db?.auth.currentUser?.id;

  // ----------------------------------------------------------
  // AUTH
  // ----------------------------------------------------------

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? language,
  }) async {
    final db = _db;
    if (db == null) return null;

    final response = await db.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name,
        'role': role,
        'language': language ?? 'en',
      },
    );

    if (response.user != null) {
      await _upsertProfile(
        response.user!.id,
        name: name,
        role: role,
        language: language ?? 'en',
      );
    }

    return response;
  }

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final db = _db;
    if (db == null) return null;

    return db.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    final db = _db;
    if (db == null) return;
    await db.auth.signOut();
  }

  Stream<AuthState>? get authStateChanges => _db?.auth.onAuthStateChange;

  // ----------------------------------------------------------
  // PROFILES
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> getProfile(String id) async {
    final db = _db;
    if (db == null) return null;

    final row = await db
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    return row;
  }

  Future<Map<String, dynamic>?> _upsertProfile(
    String id, {
    required String name,
    required String role,
    String language = 'en',
  }) async {
    final db = _db;
    if (db == null) return null;

    final row = await db.from('profiles').upsert({
      'id': id,
      'name': name,
      'role': role,
      'language': language,
    }).select().maybeSingle();

    return row;
  }

  Future<Map<String, dynamic>?> updateProfile({
    required String id,
    String? name,
    String? language,
  }) async {
    final db = _db;
    if (db == null) return null;

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (language != null) data['language'] = language;

    if (data.isEmpty) return getProfile(id);

    return db
        .from('profiles')
        .update(data)
        .eq('id', id)
        .select()
        .maybeSingle();
  }

  // ----------------------------------------------------------
  // CAREGIVER <-> PATIENT CONNECTIONS
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getConnectedPatients(
    String caregiverId,
  ) async {
    final db = _db;
    if (db == null) return [];

    final rows = await db
        .from('caregiver_patient_connections')
        .select('patient_id, status, profiles!caregiver_patient_connections_patient_id_fkey(*)')
        .eq('caregiver_id', caregiverId)
        .eq('status', 'connected');

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> getConnectedCaregivers(
    String patientId,
  ) async {
    final db = _db;
    if (db == null) return [];

    final rows = await db
        .from('caregiver_patient_connections')
        .select('caregiver_id, status, profiles!caregiver_patient_connections_caregiver_id_fkey(*)')
        .eq('patient_id', patientId)
        .eq('status', 'connected');

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>?> createConnection({
    required String caregiverId,
    required String patientId,
  }) async {
    final db = _db;
    if (db == null) return null;

    return db.from('caregiver_patient_connections').upsert({
      'caregiver_id': caregiverId,
      'patient_id': patientId,
      'status': 'connected',
    }).select().maybeSingle();
  }

  Future<void> removeConnection({
    required String caregiverId,
    required String patientId,
  }) async {
    final db = _db;
    if (db == null) return;

    await db
        .from('caregiver_patient_connections')
        .delete()
        .eq('caregiver_id', caregiverId)
        .eq('patient_id', patientId);
  }

  // ----------------------------------------------------------
  // GENERIC PATIENT-SCOPED INSERT
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> insertRecord(
    String table,
    Map<String, dynamic> data,
  ) async {
    final db = _db;
    if (db == null) return null;

    return db.from(table).insert(data).select().maybeSingle();
  }

  Future<Map<String, dynamic>?> upsertRecord(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    final db = _db;
    if (db == null) return null;

    if (onConflict == null) {
      return db.from(table).upsert(data).select().maybeSingle();
    }

    return db
        .from(table)
        .upsert(data, onConflict: onConflict)
        .select()
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> queryPatient(
    String table,
    String patientId, {
    String orderColumn = 'created_at',
    bool ascending = false,
  }) async {
    final db = _db;
    if (db == null) return [];

    final rows = await db
        .from(table)
        .select()
        .eq('patient_id', patientId)
        .order(orderColumn, ascending: ascending);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> deleteRecord(
    String table,
    String column,
    String value,
  ) async {
    final db = _db;
    if (db == null) return;

    await db.from(table).delete().eq(column, value);
  }

  // ----------------------------------------------------------
  // RUDAS
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveRudasAssessment(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord(
      'rudas_assessments',
      data,
      onConflict: 'id',
    );
  }

  Future<List<Map<String, dynamic>>> getRudasAssessments(
    String patientId,
  ) async {
    return queryPatient(
      'rudas_assessments',
      patientId,
      orderColumn: 'assessed_at',
    );
  }

  Future<List<Map<String, dynamic>>> getRudasCheckpoints(
    String patientId,
  ) async {
    return queryPatient(
      'rudas_checkpoints',
      patientId,
      orderColumn: 'created_at',
    );
  }

  Future<Map<String, dynamic>?> getLatestRudas(
    String patientId,
  ) async {
    final rows = await getRudasAssessments(patientId);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  // ----------------------------------------------------------
  // GAMES
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveGameSession(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord(
      'game_sessions',
      data,
      onConflict: 'id',
    );
  }

  Future<List<Map<String, dynamic>>> getGameSessions(
    String patientId,
  ) async {
    return queryPatient(
      'game_sessions',
      patientId,
      orderColumn: 'played_at',
    );
  }

  Future<int> countCompletedGameSessions(
    String patientId,
  ) async {
    final db = _db;
    if (db == null) return 0;

    final rows = await db
        .from('game_sessions')
        .select('id')
        .eq('patient_id', patientId)
        .eq('completed', true);

    return rows.length;
  }

  // ----------------------------------------------------------
  // TASKS
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveTask(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord('tasks', data, onConflict: 'id');
  }

  Future<List<Map<String, dynamic>>> getTasks(
    String patientId,
  ) async {
    return queryPatient(
      'tasks',
      patientId,
      orderColumn: 'due_at',
      ascending: true,
    );
  }

  // ----------------------------------------------------------
  // REMINDERS
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveReminder(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord('reminders', data, onConflict: 'id');
  }

  Future<List<Map<String, dynamic>>> getReminders(
    String patientId,
  ) async {
    return queryPatient(
      'reminders',
      patientId,
      orderColumn: 'scheduled_at',
      ascending: true,
    );
  }

  // ----------------------------------------------------------
  // MEMORY STORIES
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveMemoryStory(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord('memory_stories', data, onConflict: 'id');
  }

  Future<List<Map<String, dynamic>>> getMemoryStories(
    String patientId,
  ) async {
    return queryPatient(
      'memory_stories',
      patientId,
      orderColumn: 'created_at',
    );
  }

  // ----------------------------------------------------------
  // MEMORY PEOPLE
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveMemoryPerson(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord('memory_people', data, onConflict: 'id');
  }

  Future<List<Map<String, dynamic>>> getMemoryPeople(
    String patientId,
  ) async {
    return queryPatient(
      'memory_people',
      patientId,
      orderColumn: 'created_at',
    );
  }

  // ----------------------------------------------------------
  // MEMORY MEDIA
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveMemoryMedia(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord('memory_media', data, onConflict: 'id');
  }

  Future<List<Map<String, dynamic>>> getMemoryMedia(
    String patientId,
  ) async {
    return queryPatient(
      'memory_media',
      patientId,
      orderColumn: 'created_at',
    );
  }

  // ----------------------------------------------------------
  // MOOD
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveMood(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord('mood_entries', data, onConflict: 'id');
  }

  Future<List<Map<String, dynamic>>> getMoodEntries(
    String patientId,
  ) async {
    return queryPatient(
      'mood_entries',
      patientId,
      orderColumn: 'created_at',
    );
  }

  // ----------------------------------------------------------
  // STORY RECALL
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> saveStoryRecall(
    Map<String, dynamic> data,
  ) async {
    return upsertRecord('story_recall_events', data, onConflict: 'id');
  }

  Future<List<Map<String, dynamic>>> getStoryRecalls(
    String patientId,
  ) async {
    return queryPatient(
      'story_recall_events',
      patientId,
      orderColumn: 'created_at',
    );
  }

  // ----------------------------------------------------------
  // PRIVATE STORAGE
  // ----------------------------------------------------------

  Future<String?> uploadMemoryPhoto({
    required String patientId,
    required String mediaId,
    required Uint8List bytes,
    required String extension,
    String contentType = 'image/jpeg',
  }) async {
    final db = _db;
    if (db == null) return null;

    final path = '$patientId/photos/$mediaId.$extension';

    await db.storage.from('memory-photos').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ),
    );

    return path;
  }

  Future<String?> uploadMemoryAudio({
    required String patientId,
    required String mediaId,
    required Uint8List bytes,
    String extension = 'm4a',
    String contentType = 'audio/m4a',
  }) async {
    final db = _db;
    if (db == null) return null;

    final path = '$patientId/audio/$mediaId.$extension';

    await db.storage.from('memory-audio').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ),
    );

    return path;
  }

  Future<String?> createSignedMediaUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    final db = _db;
    if (db == null) return null;

    return db.storage
        .from(bucket)
        .createSignedUrl(path, expiresInSeconds);
  }

  Future<void> deleteMedia({
    required String bucket,
    required String path,
  }) async {
    final db = _db;
    if (db == null) return;

    await db.storage.from(bucket).remove([path]);
  }


  /// Creates or returns the patient's existing connection code.
  /// The operation is idempotent.
  Future<String> ensurePatientConnectionCode(String patientId) async {
    final response = await _client.rpc(
      'ensure_patient_connection_code',
      params: {
        'target_patient': patientId,
      },
    );

    return response.toString();
  }

  /// Connects the currently authenticated caregiver to a patient
  /// using the patient's connection code.
  Future<String> connectCaregiverByPatientCode(
    String connectionCode,
  ) async {
    final response = await _client.rpc(
      'connect_caregiver_by_patient_code',
      params: {
        'connection_code': connectionCode.trim(),
      },
    );

    return response.toString();
  }

}


  Future<void> upsertRecord({
    required String collection,
    required String recordId,
    required String patientId,
    required Map<String, dynamic> data,
  }) async {
    final allowed = {
      'game_sessions',
      'rudas_assessments',
      'tasks',
      'reminders',
      'memory_stories',
      'memory_people',
      'memory_media',
      'mood_entries',
      'story_recall_events',
    };

    if (!allowed.contains(collection)) {
      throw StateError(
        'Unsupported cloud collection.',
      );
    }

    final safeData = {
      ...data,
      'id': recordId,
      'patient_id': patientId,
    };

    await client
        .from(collection)
        .upsert(
          safeData,
          onConflict: 'id',
        );
  }

  Future<void> deleteRecord({
    required String collection,
    required String recordId,
  }) async {
    final allowed = {
      'game_sessions',
      'rudas_assessments',
      'tasks',
      'reminders',
      'memory_stories',
      'memory_people',
      'memory_media',
      'mood_entries',
      'story_recall_events',
    };

    if (!allowed.contains(collection)) {
      throw StateError(
        'Unsupported cloud collection.',
      );
    }

    await client
        .from(collection)
        .delete()
        .eq('id', recordId);
  }
