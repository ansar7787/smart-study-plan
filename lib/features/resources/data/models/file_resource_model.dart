import 'package:hive/hive.dart';
import '../../domain/entities/file_resource.dart';

part 'file_resource_model.g.dart';

@HiveType(typeId: 3)
class FileResourceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? subjectId;

  @HiveField(3)
  final String? taskId;

  @HiveField(4)
  final String name;

  @HiveField(5)
  final String type;

  @HiveField(6)
  final String url;

  @HiveField(7)
  final int size;

  @HiveField(8)
  final bool isFavorite;

  @HiveField(9)
  bool isDeleted;

  @HiveField(10)
  final DateTime createdAt;

  FileResourceModel({
    required this.id,
    required this.userId,
    this.subjectId,
    this.taskId,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.isFavorite,
    required this.isDeleted,
    required this.createdAt,
  });

  // ✅ ADD THIS
  FileResourceModel copyWith({String? url, bool? isFavorite}) {
    return FileResourceModel(
      id: id,
      userId: userId,
      subjectId: subjectId,
      taskId: taskId,
      name: name,
      type: type,
      url: url ?? this.url,
      size: size,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }

  // ---------- ENTITY ----------
  FileResource toEntity() {
    return FileResource(
      id: id,
      userId: userId,
      subjectId: subjectId,
      taskId: taskId,
      name: name,
      type: type,
      url: url,
      size: size,
      isFavorite: isFavorite,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }

  factory FileResourceModel.fromEntity(FileResource entity) {
    return FileResourceModel(
      id: entity.id,
      userId: entity.userId,
      subjectId: entity.subjectId,
      taskId: entity.taskId,
      name: entity.name,
      type: entity.type,
      url: entity.url,
      size: entity.size,
      isFavorite: entity.isFavorite,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
    );
  }

  // ---------- FIRESTORE ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subjectId': subjectId,
      'taskId': taskId,
      'name': name,
      'type': type,
      'url': url,
      'size': size,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FileResourceModel.fromJson(Map<String, dynamic> json) {
    return FileResourceModel(
      id: json['id'],
      userId: json['userId'],
      subjectId: json['subjectId'],
      taskId: json['taskId'],
      name: json['name'],
      type: json['type'],
      url: json['url'],
      size: json['size'],
      isFavorite: json['isFavorite'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
