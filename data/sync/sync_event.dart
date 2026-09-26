
class SyncEvent {
  final String id;
  final String collection;
  final String recordId;
  final String patientId;
  final String operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;

  const SyncEvent({
    required this.id,
    required this.collection,
    required this.recordId,
    required this.patientId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastError,
  });

  SyncEvent copyWith({
    int? attemptCount,
    String? lastError,
    bool clearError = false,
  }) {
    return SyncEvent(
      id: id,
      collection: collection,
      recordId: recordId,
      patientId: patientId,
      operation: operation,
      payload: payload,
      createdAt: createdAt,
      attemptCount:
          attemptCount ?? this.attemptCount,
      lastError:
          clearError
              ? null
              : (lastError ?? this.lastError),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection': collection,
      'record_id': recordId,
      'patient_id': patientId,
      'operation': operation,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'attempt_count': attemptCount,
      'last_error': lastError,
    };
  }

  factory SyncEvent.fromMap(
    Map<String, dynamic> map,
  ) {
    return SyncEvent(
      id: map['id']?.toString() ?? '',
      collection:
          map['collection']?.toString() ?? '',
      recordId:
          map['record_id']?.toString() ?? '',
      patientId:
          map['patient_id']?.toString() ?? '',
      operation:
          map['operation']?.toString() ?? 'upsert',
      payload:
          Map<String, dynamic>.from(
        map['payload'] as Map? ?? {},
      ),
      createdAt:
          DateTime.tryParse(
                map['created_at']?.toString() ?? '',
              ) ??
              DateTime.now(),
      attemptCount:
          int.tryParse(
                map['attempt_count']?.toString() ?? '0',
              ) ??
              0,
      lastError:
          map['last_error']?.toString(),
    );
  }
}
