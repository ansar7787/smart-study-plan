import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';

class UserAdminModel {
  final String id;
  final String email;
  final String name;
  final String role; // ✅ STRING for Firestore
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // ------------------------------------------------------------
  // FROM JSON (FIRESTORE → MODEL)
  // ------------------------------------------------------------
  factory UserAdminModel.fromJson(Map<String, dynamic> json) {
    return UserAdminModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // ------------------------------------------------------------
  // TO JSON (MODEL → FIRESTORE)
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ------------------------------------------------------------
  // MODEL → DOMAIN (STRING → ENUM)
  // ------------------------------------------------------------
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: UserRoleX.fromString(role), // ✅ STRING → ENUM
      photoUrl: photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ------------------------------------------------------------
  // DOMAIN → MODEL (ENUM → STRING) ✅ FIXED
  // ------------------------------------------------------------
  factory UserAdminModel.fromUserEntity(User user) {
    return UserAdminModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role.value, // ✅ ENUM → STRING
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
