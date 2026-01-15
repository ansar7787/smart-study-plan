import 'package:flutter/material.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/home/home_path_step.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/home/home_path_timeline_item.dart';

class HomeStudyPath extends StatelessWidget {
  const HomeStudyPath({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final steps = [
      HomePathStep(
        icon: Icons.menu_book,
        title: 'Create subjects',
        subtitle: 'Organize what you want to study',
        color: Colors.teal,
      ),
      HomePathStep(
        icon: Icons.check_circle_outline,
        title: 'Add tasks',
        subtitle: 'Break subjects into tasks',
        color: Colors.blue,
      ),
      HomePathStep(
        icon: Icons.calendar_today,
        title: 'Plan sessions',
        subtitle: 'Schedule your study time',
        color: Colors.indigo,
      ),
      HomePathStep(
        icon: Icons.notifications_active,
        title: 'Set reminders',
        subtitle: 'Never miss a session',
        color: Colors.orange,
      ),

      // ✅ NEW: RESOURCES STEP
      HomePathStep(
        icon: Icons.folder_open,
        title: 'Save resources',
        subtitle: 'Store PDFs, images & files',
        color: Colors.deepPurple,
      ),

      HomePathStep(
        icon: Icons.lightbulb_outline,
        title: 'Save knowledge',
        subtitle: 'Store notes & ideas',
        color: Colors.green,
      ),
      HomePathStep(
        icon: Icons.insights,
        title: 'Track progress',
        subtitle: 'See how far you’ve come',
        color: Colors.purple,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your study path',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          steps.length,
          (i) => HomePathTimelineItem(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
        ),
      ],
    );
  }
}
