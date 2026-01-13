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
  }) : super(KnowledgeInitial()) {
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
    emit(KnowledgeLoading());

    final result = await getItems(event.userId, type: event.type);

    result.fold((failure) => emit(KnowledgeError(failure.message)), (items) {
      final filtered = event.subjectId == null
          ? items
          : items.where((e) => e.subjectId == event.subjectId).toList();

      emit(KnowledgeLoaded(filtered));
    });
  }

  // ---------------- CREATE ----------------

  Future<void> _onCreate(
    CreateKnowledgeItemEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    emit(KnowledgeLoading());

    final result = await createItem(event.item);

    result.fold((failure) => emit(KnowledgeError(failure.message)), (_) {
      // ✅ Reload with SAME filters
      add(
        LoadKnowledgeItemsEvent(
          userId: event.item.userId,
          type: event.item.type,
          subjectId: event.item.subjectId, // ✅ CORRECT PLACE
        ),
      );
    });
  }

  // ---------------- UPDATE ----------------

  Future<void> _onUpdate(
    UpdateKnowledgeItemEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    final currentState = state;

    // 1️⃣ Optimistically update UI FIRST
    if (currentState is KnowledgeLoaded) {
      final updatedItems = currentState.items.map((item) {
        return item.id == event.item.id ? event.item : item;
      }).toList();

      emit(KnowledgeLoaded(updatedItems));
    }

    // 2️⃣ Persist change
    final result = await updateItem(event.item);

    result.fold(
      (failure) {
        emit(KnowledgeError(failure.message));
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
    final currentState = state;

    // 1️⃣ Optimistically update UI
    if (currentState is KnowledgeLoaded) {
      final updatedItems = currentState.items
          .where((e) => e.id != event.id)
          .toList();

      emit(KnowledgeLoaded(updatedItems));
    }

    // 2️⃣ Persist deletion
    final result = await deleteItem(event.id);

    result.fold(
      (failure) {
        emit(KnowledgeError(failure.message));
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
    emit(AiActionRunning());

    final result = await runAiAction(action: event.action, input: event.input);

    result.fold(
      (failure) => emit(KnowledgeError(failure.message)),
      (output) => emit(AiActionCompleted(output)),
    );
  }
}
