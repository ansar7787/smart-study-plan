import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadService {
  final FirebaseStorage _storage;

  FileUploadService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String userId,
    required String fileName,
    required String fileType,
    void Function(double)? onProgress,
  }) async {
    try {
      final String storagePath = 'users/$userId/resources/$fileType/$fileName';
      final Reference ref = _storage.ref().child(storagePath);

      final UploadTask uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;
      final String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
    } catch (e) {
      throw Exception('File deletion failed: $e');
    }
  }

  String detectFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (extension == 'pdf') {
      return 'pdf';
    } else if (['doc', 'docx', 'txt', 'pages'].contains(extension)) {
      return 'document';
    } else if (['mp4', 'avi', 'mov', 'mkv'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(extension)) {
      return 'audio';
    } else {
      return 'document';
    }
  }
}
