import 'package:flutter/material.dart';
import 'package:smart_study_plan/core/widgets/app_shimmer.dart';

class DashboardCardSkeleton extends StatelessWidget {
  const DashboardCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppShimmer(width: 100, height: 14),
              const AppShimmer.round(size: 32),
            ],
          ),
          const Spacer(),
          const AppShimmer(width: 80, height: 28),
          const SizedBox(height: 8),
          const AppShimmer(width: 120, height: 12),
        ],
      ),
    );
  }
}
