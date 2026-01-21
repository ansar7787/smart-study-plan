import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/file_resource.dart';

abstract class ResourceEvent extends Equatable {
  const ResourceEvent();

  @override
  List<Object?> get props => [];
}

/// Load all resources for a user
class LoadResourcesByUserEvent extends ResourceEvent {
  final String userId;
  const LoadResourcesByUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// ✅ NEW: Load resources for a subject
class LoadResourcesBySubjectEvent extends ResourceEvent {
  final String subjectId;
  const LoadResourcesBySubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

/// Upload a resource
class UploadResourceEvent extends ResourceEvent {
  final FileResource resource;
  final File file;

  const UploadResourceEvent({required this.resource, required this.file});

  @override
  List<Object?> get props => [resource, file];
}

/// Delete resource
class DeleteResourceEvent extends ResourceEvent {
  final String id;
  final String userId;
  final String? subjectId; // ✅ ADD THIS

  const DeleteResourceEvent({
    required this.id,
    required this.userId,
    this.subjectId,
  });

  @override
  List<Object?> get props => [id, userId, subjectId];
}

class SoftDeleteResourceEvent extends ResourceEvent {
  final FileResource resource;
  const SoftDeleteResourceEvent(this.resource);
  @override
  List<Object?> get props => [resource];
}

class RestoreResourceEvent extends ResourceEvent {
  final FileResource resource;
  const RestoreResourceEvent(this.resource);
  @override
  List<Object?> get props => [resource];
}

/// Toggle favorite
class ToggleFavoriteResourceEvent extends ResourceEvent {
  final FileResource resource;

  const ToggleFavoriteResourceEvent(this.resource);

  @override
  List<Object?> get props => [resource];
}

/// 🔹 NEW: progress event
class UploadProgressEvent extends ResourceEvent {
  final double progress; // 0.0 → 1.0
  const UploadProgressEvent(this.progress);
}
