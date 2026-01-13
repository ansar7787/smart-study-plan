import 'package:smart_study_plan/features/analytics/domain/entities/study_goal.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

// Generic result types
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = ResultFuture<void>;
typedef ReminderResult = ResultFuture<Reminder>;
typedef RemindersResult = ResultFuture<List<Reminder>>;
typedef ReminderVoid = ResultVoid;

// Analytics-specific
typedef StudyGoalResult = ResultFuture<StudyGoal>;
typedef StudyGoalsResult = ResultFuture<List<StudyGoal>>;
typedef StreakResult = ResultFuture<int>;
