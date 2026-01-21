import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_knowledge_items_usecase.dart';
import '../../domain/usecases/create_knowledge_item_usecase.dart';
import '../../domain/usecases/update_knowledge_item_usecase.dart';
import '../../domain/usecases/delete_knowledge_item_usecase.dart';
import '../../domain/usecases/run_ai_action_usecase.dart';

import 'knowledge_event.dart';
import 'knowledge_state.dart';

class KnowledgeBloc extends Bloc<KnowledgeEvent, KnowledgeState> {
  final GetKnowledgeItemsUseCase getItems;
  final CreateKnowledgeItemUseCase createItem;
  final UpdateKnowledgeItemUseCase updateItem;
  final DeleteKnowledgeItemUseCase deleteItem;
  final RunAiActionUseCase runAiAction;

  KnowledgeBloc({
    required this.getItems,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
    required this.runAiAction,
  }) : super(const KnowledgeState()) {
    on<LoadKnowledgeItemsEvent>(_onLoad);
    on<CreateKnowledgeItemEvent>(_onCreate);
    on<UpdateKnowledgeItemEvent>(_onUpdate);
    on<DeleteKnowledgeItemEvent>(_onDelete);
    on<RunAiActionEvent>(_onRunAi);
  }

  // ---------------- LOAD ----------------

  Future<void> _onLoad(
    LoadKnowledgeItemsEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    emit(state.copyWith(status: KnowledgeStatus.loading));

    final result = await getItems(event.userId, type: event.type);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: KnowledgeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) {
        var filtered = event.subjectId == null
            ? items
            : event.subjectId == 'UNCATEGORIZED'
            ? items.where((e) => e.subjectId == null).toList()
            : items.where((e) => e.subjectId == event.subjectId).toList();

        // 🔍 [NEW] Apply Search Filter
        if (event.query != null && event.query!.isNotEmpty) {
          final q = event.query!.toLowerCase();
          filtered = filtered.where((e) {
            final title = e.title.toLowerCase();
            final content = e.content.toLowerCase();
            return title.contains(q) || content.contains(q);
          }).toList();
        }

        emit(state.copyWith(status: KnowledgeStatus.success, items: filtered));
      },
    );
  }

  // ---------------- CREATE ----------------

  Future<void> _onCreate(
    CreateKnowledgeItemEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    emit(state.copyWith(status: KnowledgeStatus.loading));

    final result = await createItem(event.item);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: KnowledgeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        // ✅ Reload with SAME filters
        add(
          LoadKnowledgeItemsEvent(
            userId: event.item.userId,
            type: event.item.type,
            subjectId: event.item.subjectId,
          ),
        );
      },
    );
  }

  // ---------------- UPDATE ----------------

  Future<void> _onUpdate(
    UpdateKnowledgeItemEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    // 1️⃣ Optimistically update UI FIRST
    final updatedItems = state.items.map((item) {
      return item.id == event.item.id ? event.item : item;
    }).toList();

    emit(state.copyWith(items: updatedItems, status: KnowledgeStatus.success));

    // 2️⃣ Persist change
    final result = await updateItem(event.item);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: KnowledgeStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        // ✅ Do NOTHING here — UI already updated
      },
    );
  }

  // ---------------- DELETE ----------------

  Future<void> _onDelete(
    DeleteKnowledgeItemEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    // 1️⃣ Optimistically update UI
    final updatedItems = state.items.where((e) => e.id != event.id).toList();
    emit(state.copyWith(items: updatedItems, status: KnowledgeStatus.success));

    // 2️⃣ Persist deletion
    final result = await deleteItem(event.id);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: KnowledgeStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        // ✅ UI already updated — do nothing
      },
    );
  }

  // ---------------- AI ----------------

  Future<void> _onRunAi(
    RunAiActionEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    emit(state.copyWith(aiStatus: AiStatus.loading));

    final result = await runAiAction(
      userId: event.userId,
      action: event.action,
      input: event.input,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          aiStatus: AiStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (output) =>
          emit(state.copyWith(aiStatus: AiStatus.success, aiResult: output)),
    );
  }
}
