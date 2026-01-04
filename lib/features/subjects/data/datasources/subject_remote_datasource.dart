import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_study_plan/core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/subject_model.dart';

abstract class SubjectRemoteDatasource {
  Future<SubjectModel> createSubject(SubjectModel subject);
  Future<SubjectModel> getSubject(String id);
  Future<List<SubjectModel>> getSubjectsByUser(String userId);
  Future<List<SubjectModel>> getAllSubjects();
  Future<SubjectModel> updateSubject(SubjectModel subject);
  Future<void> deleteSubject(String id);
}

class SubjectRemoteDatasourceImpl implements SubjectRemoteDatasource {
  final FirebaseFirestore firestore;

  SubjectRemoteDatasourceImpl({required this.firestore});

  final String _collection = 'subjects';

  @override
  Future<SubjectModel> createSubject(SubjectModel subject) async {
    try {
      final docRef = firestore.collection(_collection).doc(subject.id);
      await docRef.set(subject.toJson());
      AppLogger.d('Subject created: ${subject.id}');
      return subject;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<SubjectModel> getSubject(String id) async {
    try {
      final doc = await firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw ServerException('Subject not found');
      }
      return SubjectModel.fromJson(doc.data() ?? {});
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<List<SubjectModel>> getSubjectsByUser(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map((doc) => SubjectModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final querySnapshot = await firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => SubjectModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<SubjectModel> updateSubject(SubjectModel subject) async {
    try {
      await firestore
          .collection(_collection)
          .doc(subject.id)
          .update(subject.toJson());
      AppLogger.d('Subject updated: ${subject.id}');
      return subject;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<void> deleteSubject(String id) async {
    try {
      await firestore.collection(_collection).doc(id).delete();
      AppLogger.d('Subject deleted: $id');
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }
}
