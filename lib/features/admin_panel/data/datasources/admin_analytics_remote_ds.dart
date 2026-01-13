import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_progress_model.dart';

abstract class AdminAnalyticsRemoteDatasource {
  Future<List<UserProgressModel>> getAllUserProgress();
  Future<UserProgressModel> getUserProgress(String userId);
}

class AdminAnalyticsRemoteDatasourceImpl
    implements AdminAnalyticsRemoteDatasource {
  final FirebaseFirestore firestore;

  AdminAnalyticsRemoteDatasourceImpl(this.firestore);

  @override
  Future<List<UserProgressModel>> getAllUserProgress() async {
    try {
      final snapshot = await firestore
          .collection('user_progress') // ✅ FIXED
          .orderBy('lastUpdated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserProgressModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw AuthFirebaseException('Failed to load user progress: $e');
    }
  }

  @override
  Future<UserProgressModel> getUserProgress(String userId) async {
    try {
      final doc = await firestore
          .collection('user_progress') // ✅ FIXED
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw AuthFirebaseException('User progress not found');
      }

      return UserProgressModel.fromJson(doc.data()!);
    } catch (e) {
      throw AuthFirebaseException('Failed to load user progress: $e');
    }
  }
}
