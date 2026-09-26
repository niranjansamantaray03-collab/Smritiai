import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_store.dart';

class SharedPreferencesStore implements LocalStore {
  SharedPreferencesStore._(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesStore._(prefs);
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<List<String>> keys() async {
    return _prefs.getKeys().toList();
  }
}
