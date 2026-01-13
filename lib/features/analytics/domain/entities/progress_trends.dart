import 'package:equatable/equatable.dart';

class ProgressTrends extends Equatable {
  final List<double> dailyStudyHours;
  final List<double> dailyTaskCompletion;
  final int studyStreak;

  const ProgressTrends({
    required this.dailyStudyHours,
    required this.dailyTaskCompletion,
    required this.studyStreak,
  });

  @override
  List<Object?> get props => [
    dailyStudyHours,
    dailyTaskCompletion,
    studyStreak,
  ];
}
