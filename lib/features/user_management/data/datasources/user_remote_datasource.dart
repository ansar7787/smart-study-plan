import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

abstract class UserRemoteDatasource {
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> loginUser({
    required String email,
    required String password,
  });

  Future<void> logoutUser();

  Future<void> resetPassword(String email);

  Future<UserModel?> getCurrentUser();

  Future<UserModel> getUser(String userId);

  Future<void> updateUser(UserModel user);

  Future<void> deleteUser(String userId);

  Future<String> uploadProfilePhoto({
    required String userId,
    required File file,
  });
}

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  UserRemoteDatasourceImpl(this.auth, this.firestore, this.storage);

  @override
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    final now = DateTime.now();

    final model = UserModel(
      id: user.uid,
      email: email,
      name: name,
      role: 'student', // 🔐 FORCE
      createdAt: now,
      updatedAt: now,
    );

    await firestore.collection('users').doc(user.uid).set(model.toJson());
    return model;
  }

  @override
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final cred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await firestore.collection('users').doc(cred.user!.uid).get();

    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<void> logoutUser() async => auth.signOut();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;

    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<UserModel> getUser(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await firestore.collection('users').doc(user.id).update({
      'name': user.name,
      'photoUrl': user.photoUrl,
      'updatedAt': user.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<String> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    final ref = storage.ref().child('avatars/$userId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteUser(String userId) async {
    await firestore.collection('users').doc(userId).delete();
  }

  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }
}
