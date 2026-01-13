import 'package:flutter/material.dart';
import '../../domain/entities/analytics_insight.dart';

class InsightsList extends StatelessWidget {
  final List<AnalyticsInsight> insights;

  const InsightsList({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...insights.map(
          (i) => Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.lightbulb),
              title: Text(i.message),
            ),
          ),
        ),
      ],
    );
  }
}
