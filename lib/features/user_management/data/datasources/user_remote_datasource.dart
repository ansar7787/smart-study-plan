import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

abstract class UserRemoteDatasource {
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<UserModel> loginUser({
    required String email,
    required String password,
  });

  Future<void> logoutUser();

  Future<UserModel> getUser(String userId);

  Future<void> updateUser(UserModel user);

  Future<UserModel?> getCurrentUser();
}

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  UserRemoteDatasourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthFirebaseException('User creation failed');
      }

      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      AppLogger.d('User registered: $email with role: $role');
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFirebaseException(
        e.message ?? 'Registration failed',
        code: e.code,
      );
    } catch (e) {
      throw AuthFirebaseException('Registration failed: $e');
    }
  }

  @override
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthFirebaseException('Login failed');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw AuthFirebaseException('User profile not found');
      }

      AppLogger.d('User logged in: $email');
      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw AuthFirebaseException(e.message ?? 'Login failed', code: e.code);
    } catch (e) {
      throw AuthFirebaseException('Login failed: $e');
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await _firebaseAuth.signOut();
      AppLogger.d('User logged out');
    } catch (e) {
      throw AuthFirebaseException('Logout failed: $e');
    }
  }

  @override
  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw AuthFirebaseException('User not found');
      }

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw AuthFirebaseException('Failed to get user: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'name': user.name,
        'photoUrl': user.photoUrl,
        'updatedAt': user.updatedAt.toIso8601String(),
      });
      AppLogger.d('User updated: ${user.id}');
    } catch (e) {
      throw AuthFirebaseException('Failed to update user: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('Failed to get current user: $e');
      return null;
    }
  }
}
