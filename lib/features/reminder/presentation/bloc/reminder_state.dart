import 'package:equatable/equatable.dart';
import '../../domain/entities/reminder.dart';

enum ReminderBlocStatus { initial, loading, success, failure }

class ReminderState extends Equatable {
  final ReminderBlocStatus status;
  final List<Reminder> reminders;
  final String? errorMessage;

  const ReminderState({
    this.status = ReminderBlocStatus.initial,
    this.reminders = const [],
    this.errorMessage,
  });

  ReminderState copyWith({
    ReminderBlocStatus? status,
    List<Reminder>? reminders,
    String? errorMessage,
  }) {
    return ReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reminders, errorMessage];
}
