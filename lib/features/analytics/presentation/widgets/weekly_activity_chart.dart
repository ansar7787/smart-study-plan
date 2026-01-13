import 'package:flutter/material.dart';

class WeeklyActivityChart extends StatefulWidget {
  final List<double> studyHours; // e.g. [1.5, 2, 0, 3, ...]
  final List<double> taskCompletion; // e.g. [0.4, 0.8, 0.2, ...]

  const WeeklyActivityChart({
    super.key,
    required this.studyHours,
    required this.taskCompletion,
  });

  @override
  State<WeeklyActivityChart> createState() => _WeeklyActivityChartState();
}

class _WeeklyActivityChartState extends State<WeeklyActivityChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Row(
              children: const [
                Text(
                  'Weekly Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ---------------- TABS ----------------
            TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(text: 'Study Hours'),
                Tab(text: 'Task Completion'),
              ],
            ),

            const SizedBox(height: 16),

            // ---------------- CHART ----------------
            SizedBox(
              height: 160,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BarChart(
                    values: widget.studyHours,
                    days: _days,
                    maxValue: 8, // max study hours/day
                    barColor: Colors.teal,
                    valueFormatter: (v) => '${v.toStringAsFixed(1)}h',
                  ),
                  _BarChart(
                    values: widget.taskCompletion.map((e) => e * 100).toList(),
                    days: _days,
                    maxValue: 100,
                    barColor: Colors.deepPurple,
                    valueFormatter: (v) => '${v.round()}%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> days;
  final double maxValue;
  final Color barColor;
  final String Function(double) valueFormatter;

  const _BarChart({
    required this.values,
    required this.days,
    required this.maxValue,
    required this.barColor,
    required this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (i) {
        final double value = i < values.length ? values[i] : 0.0;

        final double normalized = (value / maxValue).clamp(0.0, 1.0);

        final double barHeight = (normalized * 90).clamp(6.0, 90.0).toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // VALUE LABEL
            Text(
              valueFormatter(value),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),

            // BAR
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              height: barHeight,
              width: 12,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 6),

            // DAY LABEL
            Text(
              days[i],
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        );
      }),
    );
  }
}
