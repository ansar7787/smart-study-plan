import 'package:flutter/material.dart';
import '../../domain/entities/study_goal.dart';

class ActiveGoalsSection extends StatelessWidget {
  final List<StudyGoal> goals;

  const ActiveGoalsSection({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Goals',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...goals.map(
          (g) => Card(
            elevation: 0,
            child: ListTile(
              title: Text(g.title),
              subtitle: LinearProgressIndicator(
                value: (g.progress / g.targetValue).clamp(0, 1),
              ),
              trailing: Text(
                '${g.progress.toStringAsFixed(0)}/${g.targetValue.toStringAsFixed(0)}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
