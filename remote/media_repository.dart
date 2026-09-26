
abstract class MediaRepository {
  Future<String?> uploadPhoto({
    required String patientId,
    required String localPath,
    required String fileName,
  });

  Future<String?> uploadAudio({
    required String patientId,
    required String localPath,
    required String fileName,
  });

  Future<void> deleteMedia({
    required String patientId,
    required String path,
  });
}
