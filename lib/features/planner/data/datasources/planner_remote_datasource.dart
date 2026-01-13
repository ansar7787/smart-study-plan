import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_study_plan/features/planner/data/models/study_session_model.dart';

abstract class PlannerRemoteDataSource {
  Future<void> createSession(StudySessionModel session);
  Future<void> updateSession(StudySessionModel session);
  Future<void> deleteSession(String sessionId);
  Future<List<StudySessionModel>> getSessionsByDate(DateTime date);
  Future<List<StudySessionModel>> getSessionsByUser(String userId);
}

class PlannerRemoteDataSourceImpl implements PlannerRemoteDataSource {
  final FirebaseFirestore firestore;

  PlannerRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createSession(StudySessionModel session) async {
    await firestore
        .collection('studySessions')
        .doc(session.id)
        .set(session.toJson());
  }

  @override
  Future<void> updateSession(StudySessionModel session) async {
    await firestore
        .collection('studySessions')
        .doc(session.id)
        .update(session.toJson());
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await firestore.collection('studySessions').doc(sessionId).delete();
  }

  @override
  Future<List<StudySessionModel>> getSessionsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await firestore
        .collection('studySessions')
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThan: endOfDay)
        .orderBy('startTime')
        .get();

    return querySnapshot.docs
        .map((doc) => StudySessionModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<StudySessionModel>> getSessionsByUser(String userId) async {
    final querySnapshot = await firestore
        .collection('studySessions')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime')
        .get();

    return querySnapshot.docs
        .map((doc) => StudySessionModel.fromJson(doc.data()))
        .toList();
  }
}
