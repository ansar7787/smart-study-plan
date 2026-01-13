import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/usecases/create_reminder_usecase.dart';
import '../../domain/usecases/delete_reminder_usecase.dart';
import '../../domain/usecases/get_reminders_usecase.dart';
import '../../domain/usecases/toggle_reminder_usecase.dart';
import '../../domain/usecases/mark_reminder_triggered_usecase.dart';

import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final CreateReminderUseCase createReminder;
  final GetRemindersUseCase getReminders;
  final ToggleReminderUseCase toggleReminder;
  final DeleteReminderUseCase deleteReminder;
  final MarkReminderTriggeredUseCase markTriggered;

  String? _currentUserId;

  ReminderBloc({
    required this.createReminder,
    required this.getReminders,
    required this.toggleReminder,
    required this.deleteReminder,
    required this.markTriggered,
  }) : super(ReminderInitial()) {
    on<GetRemindersEvent>(_onGetReminders);
    on<CreateReminderEvent>(_onCreateReminder);
    on<ToggleReminderActiveEvent>(_onToggle);
    on<MarkReminderTriggeredEvent>(_onTriggered);
    on<DeleteReminderEvent>(_onDelete);
    on<MarkReminderDoneByTaskEvent>(_onDoneByTask);
  }

  // --------------------------------------------------
  // LOAD REMINDERS
  // --------------------------------------------------
  Future<void> _onGetReminders(
    GetRemindersEvent event,
    Emitter<ReminderState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(ReminderLoading());

    final result = await getReminders(event.userId);

    result.fold((failure) => emit(ReminderError(failure.message)), (reminders) {
      // auto-disable expired reminders
      final cleaned = reminders.map((r) {
        if (r.isExpired && r.isActive) {
          return r.copyWith(isActive: false, status: ReminderStatus.done);
        }
        return r;
      }).toList();

      emit(RemindersLoaded(cleaned));
    });
  }

  // --------------------------------------------------
  // CREATE REMINDER
  // --------------------------------------------------
  Future<void> _onCreateReminder(
    CreateReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await createReminder(
      CreateReminderParams(reminder: event.reminder),
    );

    result.fold((failure) => emit(ReminderError(failure.message)), (_) {
      if (_currentUserId != null) {
        add(GetRemindersEvent(_currentUserId!));
      }
    });
  }

  // --------------------------------------------------
  // TOGGLE ACTIVE
  // --------------------------------------------------
  Future<void> _onToggle(
    ToggleReminderActiveEvent event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await toggleReminder(
      ToggleReminderParams(
        reminderId: event.reminderId,
        isActive: event.isActive,
      ),
    );

    result.fold((failure) => emit(ReminderError(failure.message)), (_) {
      if (_currentUserId != null) {
        add(GetRemindersEvent(_currentUserId!));
      }
    });
  }

  // --------------------------------------------------
  // NOTIFICATION TRIGGERED
  // --------------------------------------------------
  Future<void> _onTriggered(
    MarkReminderTriggeredEvent event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await markTriggered(event.reminderId);

    result.fold((failure) => emit(ReminderError(failure.message)), (_) {
      if (_currentUserId != null) {
        add(GetRemindersEvent(_currentUserId!));
      }
    });
  }

  // --------------------------------------------------
  // DELETE REMINDER
  // --------------------------------------------------
  Future<void> _onDelete(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());

    final result = await deleteReminder(event.reminderId);

    if (emit.isDone) return;

    await result.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(ReminderError(failure.message));
        }
      },
      (_) async {
        if (_currentUserId == null) return;

        final refreshed = await getReminders(_currentUserId!);

        if (emit.isDone) return;

        refreshed.fold(
          (failure) => emit(ReminderError(failure.message)),
          (reminders) => emit(RemindersLoaded(reminders)),
        );
      },
    );
  }

  // --------------------------------------------------
  // MARK DONE BY TASK
  // --------------------------------------------------
  void _onDoneByTask(
    MarkReminderDoneByTaskEvent event,
    Emitter<ReminderState> emit,
  ) {
    if (state is! RemindersLoaded) return;

    final updated = (state as RemindersLoaded).reminders.map((r) {
      if (r.taskId == event.taskId) {
        return r.copyWith(status: ReminderStatus.done, isActive: false);
      }
      return r;
    }).toList();

    emit(RemindersLoaded(updated));
  }
}
