import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_state.dart';
import 'package:smart_study_plan/features/reminder/presentation/widgets/reminder_tile.dart';

class ReminderListPage extends StatefulWidget {
  final String userId;
  const ReminderListPage({super.key, required this.userId});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  static const _filterKey = 'reminder_filter';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadFilter();
    context.read<ReminderBloc>().add(GetRemindersEvent(widget.userId));
  }

  Future<void> _loadFilter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _filter = prefs.getString(_filterKey) ?? 'all');
  }

  Future<void> _saveFilter(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_filterKey, value);
  }

  void _changeFilter(String value) {
    setState(() => _filter = value);
    _saveFilter(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReminderError) {
            return Center(child: Text(state.message));
          }

          if (state is RemindersLoaded) {
            final reminders = state.reminders;
            final filtered = _applyFilter(reminders);

            return CustomScrollView(
              slivers: [
                // 🧲 STICKY FILTER BAR
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterHeader(
                    reminders: reminders,
                    selected: _filter,
                    onChanged: _changeFilter,
                  ),
                ),

                // 📋 LIST
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: filtered.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('No reminders')),
                        )
                      : SliverList.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final reminder = filtered[index];

                            return Dismissible(
                              key: ValueKey(reminder.id),
                              direction: DismissDirection.endToStart,

                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade500,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                              ),

                              confirmDismiss: (_) async {
                                context.read<ReminderBloc>().add(
                                  DeleteReminderEvent(
                                    reminder.id,
                                    // widget.userId,
                                  ),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reminder deleted'),
                                  ),
                                );

                                return true; // ✅ Let dismiss animation happen
                              },

                              child: ReminderTile(
                                reminder: reminder,
                                onToggle: (v) =>
                                    context.read<ReminderBloc>().add(
                                      ToggleReminderActiveEvent(reminder.id, v),
                                    ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<Reminder> _applyFilter(List<Reminder> reminders) {
    final now = DateTime.now();

    switch (_filter) {
      case 'upcoming':
        return reminders
            .where(
              (r) =>
                  r.isActive &&
                  r.status == ReminderStatus.upcoming &&
                  r.reminderTime.isAfter(now),
            )
            .toList();
      case 'task':
        return reminders.where((r) => r.reminderType == 'task').toList();
      case 'session':
        return reminders.where((r) => r.reminderType == 'session').toList();
      default:
        return reminders;
    }
  }
}

class _FilterHeader extends SliverPersistentHeaderDelegate {
  final List<Reminder> reminders;
  final String selected;
  final ValueChanged<String> onChanged;

  _FilterHeader({
    required this.reminders,
    required this.selected,
    required this.onChanged,
  });

  int _count(String type) {
    if (type == 'upcoming') {
      return reminders
          .where(
            (r) =>
                r.isActive &&
                r.status == ReminderStatus.upcoming &&
                r.reminderTime.isAfter(DateTime.now()),
          )
          .length;
    }
    if (type == 'task') {
      return reminders.where((r) => r.reminderType == 'task').length;
    }
    if (type == 'session') {
      return reminders.where((r) => r.reminderType == 'session').length;
    }
    return reminders.length;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _chip(context, 'all', 'All', _count('all')),
          _chip(context, 'upcoming', 'Upcoming', _count('upcoming')),
          _chip(context, 'task', 'Tasks', _count('task')),
          _chip(context, 'session', 'Sessions', _count('session')),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String value, String label, int count) {
    final theme = Theme.of(context);
    final isSelected = value == selected;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        onSelected: (_) => onChanged(value),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 9,
                backgroundColor: isSelected
                    ? Colors.white
                    : theme.colorScheme.primary,
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(covariant _FilterHeader oldDelegate) => true;
}
