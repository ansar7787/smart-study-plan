import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String color; // hex color code
  final String? teacher;
  final int credits;
  final String? semester;
  final String userId; // student who created/owns this subject
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
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

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    color,
    teacher,
    credits,
    semester,
    userId,
    createdAt,
    updatedAt,
  ];

  // Copy with method for updates
  Subject copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? teacher,
    int? credits,
    String? semester,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      teacher: teacher ?? this.teacher,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
