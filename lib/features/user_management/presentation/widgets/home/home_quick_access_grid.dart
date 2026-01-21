import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'home_quick_tile.dart';

class HomeQuickAccessGrid extends StatelessWidget {
  final String userId;

  const HomeQuickAccessGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick access',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
          ),
          children: [
            HomeQuickTile(
              icon: Icons.menu_book,
              label: 'Subjects',
              colors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
              onTap: () => context.pushNamed(AppRouteNames.subjects),
            ),
            HomeQuickTile(
              icon: Icons.calendar_today,
              label: 'Planner',
              colors: const [Color(0xFF6366F1), Color(0xFF4338CA)],
              onTap: () => context.pushNamed(AppRouteNames.calendar),
            ),
            HomeQuickTile(
              icon: Icons.notifications_active,
              label: 'Reminders',
              colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
              onTap: () => context.pushNamed(AppRouteNames.reminders),
            ),
            HomeQuickTile(
              icon: Icons.folder_special,
              label: 'Resources',
              colors: const [Color(0xFFA855F7), Color(0xFF7E22CE)],
              onTap: () => context.pushNamed(AppRouteNames.resources),
            ),
            HomeQuickTile(
              icon: Icons.lightbulb_outline,
              label: 'Knowledge',
              colors: const [Color(0xFF22C55E), Color(0xFF15803D)],
              onTap: () =>
                  context.pushNamed(AppRouteNames.knowledge, extra: userId),
            ),
            HomeQuickTile(
              icon: Icons.insights,
              label: 'Analytics',
              colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
              onTap: () =>
                  context.pushNamed(AppRouteNames.analytics, extra: userId),
            ),
          ],
        ),
      ],
    );
  }
}
