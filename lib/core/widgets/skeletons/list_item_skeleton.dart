import 'package:flutter/material.dart';
import 'package:smart_study_plan/core/widgets/app_shimmer.dart';

class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const AppShimmer.round(size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmer(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                AppShimmer(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
