import 'package:smart_study_plan/features/user_management/data/models/user_model.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';

class UserAdminModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int tasksCount;
  final DateTime? lastActive;

  UserAdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.tasksCount = 0,
    this.lastActive,
  });

  factory UserAdminModel.fromJson(Map<String, dynamic> json) {
    return UserAdminModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tasksCount: json['tasksCount'] as int? ?? 0,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tasksCount': tasksCount,
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: role,
      photoUrl: photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserAdminModel.fromUserModel(UserModel user) {
    return UserAdminModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
