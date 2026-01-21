import 'package:flutter/material.dart';
import 'package:smart_study_plan/core/widgets/app_shimmer.dart';

class GridItemSkeleton extends StatelessWidget {
  const GridItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppShimmer(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmer(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                AppShimmer(width: 60, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
