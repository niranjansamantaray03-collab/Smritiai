
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/security/security_policy.dart';
import 'sync_event.dart';
import 'sync_queue.dart';
import '../remote/supabase_data_service.dart';

class SyncManager {
  SyncManager._();

  static final SyncManager instance =
      SyncManager._();

  final SyncQueue _queue =
      SyncQueue.instance;

  final SupabaseDataService _cloud =
      SupabaseDataService.instance;

  StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  bool _running = false;

  Future<void> initialize() async {
    _connectivitySubscription ??=
        Connectivity()
            .onConnectivityChanged
            .listen((results) {
      final online = results.any(
        (result) =>
            result != ConnectivityResult.none,
      );

      if (online) {
        process();
      }
    });
  }

  Future<void> process() async {
    if (_running) return;

    _running = true;

    try {
      final connectivity =
          await Connectivity().checkConnectivity();

      final online = connectivity.any(
        (result) =>
            result != ConnectivityResult.none,
      );

      if (!online) return;

      final events =
          await _queue.read();

      for (final event in events) {
        if (event.attemptCount >=
            SecurityPolicy.maxSyncAttempts) {
          continue;
        }

        try {
          await _upload(event);

          await _queue.remove(
            event.id,
          );
        } catch (error) {
          final updated =
              event.copyWith(
            attemptCount:
                event.attemptCount + 1,
            lastError:
                error.toString(),
          );

          await _queue.replace(updated);
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _upload(
    SyncEvent event,
  ) async {
    if (!SecurityPolicy.validPatientId(
      event.patientId,
    )) {
      throw StateError(
        'Blocked sync: invalid patient scope.',
      );
    }

    final allowedCollections = {
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

    if (!allowedCollections.contains(
      event.collection,
    )) {
      throw StateError(
        'Blocked sync: unsupported collection.',
      );
    }

    switch (event.operation) {
      case 'delete':
        await _cloud.deleteRecord(
          collection: event.collection,
          recordId: event.recordId,
        );
        return;

      case 'upsert':
      default:
        await _cloud.upsertRecord(
          collection: event.collection,
          recordId: event.recordId,
          patientId: event.patientId,
          data: event.payload,
        );
        return;
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
