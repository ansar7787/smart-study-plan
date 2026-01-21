import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  final int aiUsageCount;
  final DateTime? lastAiUsageDate;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.aiUsageCount = 0,
    this.lastAiUsageDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'] ?? 'student',
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      aiUsageCount: json['aiUsageCount'] ?? 0,
      lastAiUsageDate: json['lastAiUsageDate'] != null
          ? DateTime.parse(json['lastAiUsageDate'])
          : null,
    );
  }

  /// ✅ REQUIRED METHOD
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role.value,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      aiUsageCount: user.aiUsageCount,
      lastAiUsageDate: user.lastAiUsageDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'aiUsageCount': aiUsageCount,
    'lastAiUsageDate': lastAiUsageDate?.toIso8601String(),
  };

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: UserRoleX.fromString(role),
      photoUrl: photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      aiUsageCount: aiUsageCount,
      lastAiUsageDate: lastAiUsageDate,
    );
  }
}
