import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/resources/domain/usecases/restore_resource.dart';
import 'package:smart_study_plan/features/resources/domain/usecases/soft_delete_resource.dart';
import '../../domain/entities/file_resource.dart';

import '../../domain/usecases/get_resources_by_subject.dart';
import '../../domain/usecases/get_resources_by_user.dart';
import '../../domain/usecases/toggle_favorite_resource.dart';
import '../../domain/usecases/upload_resource.dart';
import 'resource_event.dart';
import 'resource_state.dart';

class ResourceBloc extends Bloc<ResourceEvent, ResourceState> {
  final GetResourcesByUserUsecase getByUser;
  final GetResourcesBySubjectUsecase getBySubject;
  final UploadResourceUsecase upload;
  final SoftDeleteResourceUsecase softDelete;
  final RestoreResourceUsecase restore;
  final ToggleFavoriteResourceUsecase toggleFavorite;

  ResourceBloc({
    required this.getByUser,
    required this.getBySubject,
    required this.upload,
    required this.softDelete,
    required this.restore,
    required this.toggleFavorite,
  }) : super(const ResourceState()) {
    on<LoadResourcesByUserEvent>(_onLoadByUser);
    on<LoadResourcesBySubjectEvent>(_onLoadBySubject);
    on<UploadResourceEvent>(_onUpload);
    on<SoftDeleteResourceEvent>(_onSoftDelete);
    on<RestoreResourceEvent>(_onRestore);
    on<ToggleFavoriteResourceEvent>(_onToggleFavorite);
    on<UploadProgressEvent>(_onUploadProgress);
  }

  // ================= LOAD =================

  Future<void> _onLoadByUser(
    LoadResourcesByUserEvent event,
    Emitter<ResourceState> emit,
  ) async {
    emit(state.copyWith(status: ResourceStatus.loading, resources: []));

    final result = await getByUser(event.userId);
    result.fold(
      (f) => emit(
        state.copyWith(status: ResourceStatus.failure, errorMessage: f.message),
      ),
      (r) {
        final total = r.fold<double>(0, (sum, item) => sum + item.size);
        emit(
          state.copyWith(
            status: ResourceStatus.success,
            resources: r,
            totalStorageUsed: total,
          ),
        );
      },
    );
  }

  Future<void> _onLoadBySubject(
    LoadResourcesBySubjectEvent event,
    Emitter<ResourceState> emit,
  ) async {
    emit(state.copyWith(status: ResourceStatus.loading, resources: []));

    final result = await getBySubject(event.subjectId);
    result.fold(
      (f) => emit(
        state.copyWith(status: ResourceStatus.failure, errorMessage: f.message),
      ),
      (r) => emit(state.copyWith(status: ResourceStatus.success, resources: r)),
    );
  }

  // ================= UPLOAD =================

  Future<void> _onUpload(
    UploadResourceEvent event,
    Emitter<ResourceState> emit,
  ) async {
    // Keep showing loading but with reset progress
    emit(state.copyWith(status: ResourceStatus.loading, uploadProgress: 0.0));

    final result = await upload(
      UploadResourceParams(
        resource: event.resource,
        file: event.file,
        onProgress: (p) {
          add(UploadProgressEvent(p));
        },
      ),
    );

    result.fold(
      (f) => emit(
        state.copyWith(status: ResourceStatus.failure, errorMessage: f.message),
      ),
      (_) => _refresh(event.resource),
    );
  }

  void _onUploadProgress(
    UploadProgressEvent event,
    Emitter<ResourceState> emit,
  ) {
    emit(state.copyWith(uploadProgress: event.progress));
  }

  // ================= SOFT DELETE =================

  Future<void> _onSoftDelete(
    SoftDeleteResourceEvent event,
    Emitter<ResourceState> emit,
  ) async {
    // optimistically update? For now just loading
    emit(state.copyWith(status: ResourceStatus.loading));

    final result = await softDelete(event.resource);

    result.fold(
      (f) => emit(
        state.copyWith(status: ResourceStatus.failure, errorMessage: f.message),
      ),
      (_) => _refresh(event.resource),
    );
  }

  // ================= RESTORE =================

  Future<void> _onRestore(
    RestoreResourceEvent event,
    Emitter<ResourceState> emit,
  ) async {
    emit(state.copyWith(status: ResourceStatus.loading));

    final result = await restore(event.resource);

    result.fold(
      (f) => emit(
        state.copyWith(status: ResourceStatus.failure, errorMessage: f.message),
      ),
      (_) => _refresh(event.resource),
    );
  }

  // ================= FAVORITE =================

  Future<void> _onToggleFavorite(
    ToggleFavoriteResourceEvent event,
    Emitter<ResourceState> emit,
  ) async {
    // Optimistic Update
    final currentResources = List<FileResource>.from(state.resources);
    final index = currentResources.indexWhere((r) => r.id == event.resource.id);
    if (index != -1) {
      currentResources[index] = event.resource.copyWith(
        isFavorite: !event.resource.isFavorite,
      );
      emit(state.copyWith(resources: currentResources));
    }

    final result = await toggleFavorite(event.resource);

    result.fold(
      (f) => emit(
        state.copyWith(status: ResourceStatus.failure, errorMessage: f.message),
      ),
      (_) {
        // success, already updated optimistically
      },
    );
  }

  // ================= HELPER =================

  void _refresh(FileResource resource) {
    // Always refresh full list to update total storage usage
    add(LoadResourcesByUserEvent(resource.userId));
    if (resource.subjectId != null) {
      add(LoadResourcesBySubjectEvent(resource.subjectId!));
    }
  }
}
