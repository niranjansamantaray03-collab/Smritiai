
class PersistenceRecord {
  const PersistenceRecord({
    required this.collection,
    required this.id,
    required this.data,
    required this.updatedAt,
  });

  final String collection;
  final String id;
  final Map<String, dynamic> data;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'collection': collection,
        'id': id,
        'data': data,
        'updated_at':
            updatedAt.toIso8601String(),
      };

  factory PersistenceRecord.fromMap(
    Map<String, dynamic> map,
  ) {
    return PersistenceRecord(
      collection:
          map['collection'] as String? ?? '',
      id: map['id'] as String? ?? '',
      data: Map<String, dynamic>.from(
        map['data'] as Map? ?? {},
      ),
      updatedAt:
          DateTime.tryParse(
                map['updated_at']
                        as String? ??
                    '',
              ) ??
              DateTime.now(),
    );
  }
}
