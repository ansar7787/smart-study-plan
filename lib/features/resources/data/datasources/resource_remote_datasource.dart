import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/file_resource_model.dart';

abstract class ResourceRemoteDataSource {
  Future<void> uploadResource(FileResourceModel model);
  Future<List<FileResourceModel>> getResourcesByUser(String userId);
  Future<List<FileResourceModel>> getResourcesBySubject(String subjectId);
  Future<void> deleteResource(String id);
}

class ResourceRemoteDataSourceImpl implements ResourceRemoteDataSource {
  final FirebaseFirestore firestore;

  ResourceRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _collection => firestore.collection('resources');

  @override
  Future<void> uploadResource(FileResourceModel model) async {
    await _collection.doc(model.id).set(model.toJson());
  }

  @override
  Future<List<FileResourceModel>> getResourcesByUser(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (e) => FileResourceModel.fromJson(e.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<FileResourceModel>> getResourcesBySubject(
    String subjectId,
  ) async {
    final snapshot = await _collection
        .where('subjectId', isEqualTo: subjectId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (e) => FileResourceModel.fromJson(e.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> deleteResource(String id) async {
    await _collection.doc(id).delete();
  }
}
