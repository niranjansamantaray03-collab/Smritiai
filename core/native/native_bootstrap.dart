import 'dart:async';

import 'package:flutter/foundation.dart';
import '../backend/production_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../backend/backend_config.dart';

class NativeBootstrap {
  NativeBootstrap._();

  static bool _initialized = false;
  static bool _supabaseReady = false;
  static bool _online = true;

  static bool get initialized => _initialized;
  static bool get supabaseReady => _supabaseReady;
  static bool get online => _online;

  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  static Future<void> initialize() async {
    await ProductionBackend.instance.initialize();
    if (_initialized) return;

    // Initialize SharedPreferences early so durable app state is available.
    await SharedPreferences.getInstance();

    // Supabase is optional during local/offline/demo development.
    final url = BackendConfig.supabaseUrl;
    final anonKey = BackendConfig.supabaseAnonKey;

    if (url.isNotEmpty && anonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
          debug: kDebugMode,
        );
        _supabaseReady = true;
      } catch (e) {
        debugPrint('SmritiAI Supabase initialization skipped: $e');
      }
    }

    try {
      final connectivity = await Connectivity().checkConnectivity();
      _online = connectivity.any((item) => item != ConnectivityResult.none);

      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((results) {
        _online = results.any(
          (item) => item != ConnectivityResult.none,
        );
      });
    } catch (e) {
      debugPrint('SmritiAI connectivity initialization skipped: $e');
    }

    _initialized = true;
  }

  static Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
