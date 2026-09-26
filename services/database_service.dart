class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  final Map<String, dynamic> _memory = {};

  Future<void> initialize() async {}

  Future<void> save(String key, dynamic value) async {
    _memory[key] = value;
  }

  T? get<T>(String key) {
    final value = _memory[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  Future<void> delete(String key) async {
    _memory.remove(key);
  }

  Future<void> clear() async {
    _memory.clear();
  }
}
