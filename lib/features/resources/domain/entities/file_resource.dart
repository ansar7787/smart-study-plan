import 'package:equatable/equatable.dart';

class FileResource extends Equatable {
  final String id;
  final String userId;
  final String? subjectId;
  final String? taskId;
  final String name;
  final String type; // pdf | image | doc | video | audio
  final String url;
  final int size; // bytes
  final bool isFavorite;
  final bool isDeleted;
  final DateTime createdAt;

  const FileResource({
    required this.id,
    required this.userId,
    this.subjectId,
    this.taskId,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.isFavorite,
    this.isDeleted = false,
    required this.createdAt,
  });

  FileResource copyWith({bool? isFavorite, bool? isDeleted}) {
    return FileResource(
      id: id,
      userId: userId,
      subjectId: subjectId,
      taskId: taskId,
      name: name,
      type: type,
      url: url,
      size: size,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
    );
  }

  FileResource copyWithUrl(String url) {
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
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    subjectId,
    taskId,
    name,
    type,
    url,
    size,
    isFavorite,
    isDeleted,
    createdAt,
  ];
}
