import 'package:hive/hive.dart';
import 'package:smart_study_plan/features/subjects/domain/entities/subject.dart';

part 'subject_model.g.dart'; // Run: flutter pub run build_runner build

@HiveType(typeId: 0) // typeId must be unique
class SubjectModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final String? teacher;

  @HiveField(5)
  final int credits;

  @HiveField(6)
  final String? semester;

  @HiveField(7)
  final String userId;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    this.teacher,
    required this.credits,
    this.semester,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Entity
  Subject toEntity() {
    return Subject(
      id: id,
      name: name,
      description: description,
      color: color,
      teacher: teacher,
      credits: credits,
      semester: semester,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert from Entity
  factory SubjectModel.fromEntity(Subject subject) {
    return SubjectModel(
      id: subject.id,
      name: subject.name,
      description: subject.description,
      color: subject.color,
      teacher: subject.teacher,
      credits: subject.credits,
      semester: subject.semester,
      userId: subject.userId,
      createdAt: subject.createdAt,
      updatedAt: subject.updatedAt,
    );
  }

  // Convert from JSON (Firestore)
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      color: json['color'] ?? '#2196F3',
      teacher: json['teacher'],
      credits: json['credits'] ?? 0,
      semester: json['semester'],
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'teacher': teacher,
      'credits': credits,
      'semester': semester,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
