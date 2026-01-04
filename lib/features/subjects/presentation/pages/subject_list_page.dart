import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/subject_bloc.dart';
import '../widgets/subject_card.dart';

class SubjectListPage extends StatefulWidget {
  final String userId;

  const SubjectListPage({super.key, required this.userId});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects'), elevation: 0),
      body: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, state) {
          if (state is SubjectLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubjectListLoaded) {
            if (state.subjects.isEmpty) {
              return const Center(child: Text('No subjects yet. Add one!'));
            }
            return ListView.builder(
              itemCount: state.subjects.length,
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                return SubjectCard(
                  subject: subject,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/subject-detail',
                      arguments: subject.id,
                    );
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      '/subject-form',
                      arguments: subject,
                    );
                  },
                  onDelete: () {
                    _showDeleteDialog(context, subject.id);
                  },
                );
              },
            );
          } else if (state is SubjectError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/subject-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String subjectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: const Text('Are you sure you want to delete this subject?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SubjectBloc>().add(DeleteSubjectEvent(subjectId));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subject deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
