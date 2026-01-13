import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/resources/domain/usecases/restore_resource.dart';
import 'package:smart_study_plan/features/resources/domain/usecases/soft_delete_resource.dart';
import '../../../../core/bloc/base_bloc.dart';
import '../../../../core/bloc/base_state.dart';
import '../../domain/entities/file_resource.dart';

import '../../domain/usecases/get_resources_by_subject.dart';
import '../../domain/usecases/get_resources_by_user.dart';
import '../../domain/usecases/toggle_favorite_resource.dart';
import '../../domain/usecases/upload_resource.dart';
import 'resource_event.dart';

class ResourceBloc extends BaseBloc<ResourceEvent, List<FileResource>> {
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
  }) : super(BaseState.initial()) {
    on<LoadResourcesByUserEvent>(_onLoadByUser);
    on<LoadResourcesBySubjectEvent>(_onLoadBySubject);
    on<UploadResourceEvent>(_onUpload);
    on<SoftDeleteResourceEvent>(_onSoftDelete);
    on<RestoreResourceEvent>(_onRestore);
    on<ToggleFavoriteResourceEvent>(_onToggleFavorite);
  }

  // ================= LOAD =================

  Future<void> _onLoadByUser(
    LoadResourcesByUserEvent event,
    Emitter<BaseState<List<FileResource>>> emit,
  ) async {
    emitLoading(emit);

    final result = await getByUser(event.userId);
    result.fold((f) => emitFailure(emit, f), (r) => emitSuccess(emit, r));
  }

  Future<void> _onLoadBySubject(
    LoadResourcesBySubjectEvent event,
    Emitter<BaseState<List<FileResource>>> emit,
  ) async {
    emitLoading(emit);

    final result = await getBySubject(event.subjectId);
    result.fold((f) => emitFailure(emit, f), (r) => emitSuccess(emit, r));
  }

  // ================= UPLOAD =================

  Future<void> _onUpload(
    UploadResourceEvent event,
    Emitter<BaseState<List<FileResource>>> emit,
  ) async {
    emit(BaseState.loadingWithProgress(0));

    final result = await upload(
      UploadResourceParams(
        resource: event.resource,
        file: event.file,
        onProgress: (p) {
          emit(BaseState.loadingWithProgress(p));
        },
      ),
    );

    result.fold((f) => emitFailure(emit, f), (_) => _refresh(event.resource));
  }

  // ================= SOFT DELETE (FOLD) =================

  Future<void> _onSoftDelete(
    SoftDeleteResourceEvent event,
    Emitter<BaseState<List<FileResource>>> emit,
  ) async {
    emitLoading(emit);

    final result = await softDelete(event.resource);

    result.fold((f) => emitFailure(emit, f), (_) => _refresh(event.resource));
  }

  // ================= RESTORE (FOLD) =================

  Future<void> _onRestore(
    RestoreResourceEvent event,
    Emitter<BaseState<List<FileResource>>> emit,
  ) async {
    emitLoading(emit);

    final result = await restore(event.resource);

    result.fold((f) => emitFailure(emit, f), (_) => _refresh(event.resource));
  }

  // ================= FAVORITE =================

  Future<void> _onToggleFavorite(
    ToggleFavoriteResourceEvent event,
    Emitter<BaseState<List<FileResource>>> emit,
  ) async {
    emitLoading(emit);

    final result = await toggleFavorite(event.resource);

    result.fold((f) => emitFailure(emit, f), (_) => _refresh(event.resource));
  }

  // ================= HELPER =================

  void _refresh(FileResource resource) {
    if (resource.subjectId != null) {
      add(LoadResourcesBySubjectEvent(resource.subjectId!));
    } else {
      add(LoadResourcesByUserEvent(resource.userId));
    }
  }
}
