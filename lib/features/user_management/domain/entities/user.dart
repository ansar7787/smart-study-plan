import 'package:equatable/equatable.dart';

enum UserRole { student, admin }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.student,
    );
  }
}

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == UserRole.admin;

  /// ✅ REQUIRED FOR UPDATE FLOW
  User copyWith({String? name, String? photoUrl, DateTime? updatedAt}) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    photoUrl,
    createdAt,
    updatedAt,
  ];
}
