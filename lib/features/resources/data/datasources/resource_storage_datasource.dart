import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ResourceStorageDataSource {
  UploadTask uploadFile({
    required File file,
    required String userId,
    required String fileName,
  });
}

class ResourceStorageDataSourceImpl implements ResourceStorageDataSource {
  final FirebaseStorage storage;

  ResourceStorageDataSourceImpl(this.storage);

  @override
  UploadTask uploadFile({
    required File file,
    required String userId,
    required String fileName,
  }) {
    final ref = storage.ref().child('resources').child(userId).child(fileName);

    return ref.putFile(file);
  }
}
