import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService._();

  static final SupabaseStorageService instance =
      SupabaseStorageService._();

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadPhoto({
    required String patientId,
    required File file,
    required String fileName,
  }) async {
    final client = _client;
    if (client == null) return null;

    final path = '$patientId/$fileName';

    await client.storage
        .from('memory-photos')
        .upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return path;
  }

  Future<String?> uploadAudio({
    required String patientId,
    required File file,
    required String fileName,
  }) async {
    final client = _client;
    if (client == null) return null;

    final path = '$patientId/$fileName';

    await client.storage
        .from('memory-audio')
        .upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'audio/m4a',
          ),
        );

    return path;
  }

  Future<void> deletePhoto(String path) async {
    final client = _client;
    if (client == null) return;

    await client.storage.from('memory-photos').remove([path]);
  }

  Future<void> deleteAudio(String path) async {
    final client = _client;
    if (client == null) return;

    await client.storage.from('memory-audio').remove([path]);
  }

  Future<String?> createSignedPhotoUrl(
    String path, {
    int expiresInSeconds = 3600,
  }) async {
    final client = _client;
    if (client == null) return null;

    return client.storage
        .from('memory-photos')
        .createSignedUrl(path, expiresInSeconds);
  }

  Future<String?> createSignedAudioUrl(
    String path, {
    int expiresInSeconds = 3600,
  }) async {
    final client = _client;
    if (client == null) return null;

    return client.storage
        .from('memory-audio')
        .createSignedUrl(path, expiresInSeconds);
  }
}
