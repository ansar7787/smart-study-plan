import 'package:equatable/equatable.dart';
import '../../domain/entities/file_resource.dart';

enum ResourceStatus { initial, loading, success, failure }

class ResourceState extends Equatable {
  final ResourceStatus status;
  final List<FileResource> resources;
  final String? errorMessage;
  final double uploadProgress; // 0.0 to 1.0

  final double totalStorageUsed; // In bytes

  const ResourceState({
    this.status = ResourceStatus.initial,
    this.resources = const [],
    this.errorMessage,
    this.uploadProgress = 0.0,
    this.totalStorageUsed = 0.0,
  });

  ResourceState copyWith({
    ResourceStatus? status,
    List<FileResource>? resources,
    String? errorMessage,
    double? uploadProgress,
    double? totalStorageUsed,
  }) {
    return ResourceState(
      status: status ?? this.status,
      resources: resources ?? this.resources,
      errorMessage: errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      totalStorageUsed: totalStorageUsed ?? this.totalStorageUsed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    resources,
    errorMessage,
    uploadProgress,
    totalStorageUsed,
  ];
}
