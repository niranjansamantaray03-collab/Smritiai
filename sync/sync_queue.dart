
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sync_event.dart';

class SyncQueue {
  SyncQueue._();

  static final SyncQueue instance =
      SyncQueue._();

  static const _key = 'smritiai_secure_sync_queue_v2';

  Future<List<SyncEvent>> read() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw = prefs.getStringList(_key) ?? [];

    return raw
        .map((value) {
          try {
            return SyncEvent.fromMap(
              jsonDecode(value)
                  as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<SyncEvent>()
        .toList();
  }

  Future<void> save(
    List<SyncEvent> events,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      events
          .map(
            (event) =>
                jsonEncode(event.toMap()),
          )
          .toList(),
    );
  }

  Future<void> enqueue(
    SyncEvent event,
  ) async {
    final events = await read();

    final duplicate =
        events.any(
          (existing) =>
              existing.id == event.id ||
              (
                existing.collection ==
                    event.collection &&
                existing.recordId ==
                    event.recordId &&
                existing.operation ==
                    event.operation
              ),
        );

    if (duplicate) {
      return;
    }

    events.add(event);

    await save(events);
  }

  Future<void> remove(
    String eventId,
  ) async {
    final events = await read();

    events.removeWhere(
      (event) => event.id == eventId,
    );

    await save(events);
  }

  Future<void> replace(
    SyncEvent event,
  ) async {
    final events = await read();

    final index =
        events.indexWhere(
          (item) => item.id == event.id,
        );

    if (index >= 0) {
      events[index] = event;
    } else {
      events.add(event);
    }

    await save(events);
  }

  Future<void> clear() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}
