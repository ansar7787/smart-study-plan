import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/subject.dart';
import '../bloc/subject_bloc.dart';

class SubjectFormPage extends StatefulWidget {
  final Subject? subject;
  final String userId;

  const SubjectFormPage({super.key, this.subject, required this.userId});

  @override
  State<SubjectFormPage> createState() => _SubjectFormPageState();
}

class _SubjectFormPageState extends State<SubjectFormPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _teacherController;
  late TextEditingController _creditsController;
  late TextEditingController _semesterController;
  Color _selectedColor = const Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.subject?.description ?? '',
    );
    _teacherController = TextEditingController(
      text: widget.subject?.teacher ?? '',
    );
    _creditsController = TextEditingController(
      text: widget.subject?.credits.toString() ?? '0',
    );
    _semesterController = TextEditingController(
      text: widget.subject?.semester ?? '',
    );
    if (widget.subject != null) {
      _selectedColor = Color(
        int.parse(
          'FF${widget.subject!.color.replaceFirst('#', '')}',
          radix: 16,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _teacherController.dispose();
    _creditsController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _saveSubject() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subject name is required')));
      return;
    }

    final subject = Subject(
      id: widget.subject?.id ?? const Uuid().v4(),
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      color:
          '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      teacher: _teacherController.text.isEmpty ? null : _teacherController.text,
      credits: int.tryParse(_creditsController.text) ?? 0,
      semester: _semesterController.text.isEmpty
          ? null
          : _semesterController.text,
      userId: widget.userId,
      createdAt: widget.subject?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.subject == null) {
      context.read<SubjectBloc>().add(CreateSubjectEvent(subject));
    } else {
      context.read<SubjectBloc>().add(UpdateSubjectEvent(subject));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      ),
      body: BlocListener<SubjectBloc, SubjectState>(
        listener: (context, state) {
          if (state is SubjectCreated || state is SubjectUpdated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is SubjectCreated
                      ? 'Subject created'
                      : 'Subject updated',
                ),
              ),
            );
          } else if (state is SubjectError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Subject Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Teacher
              TextField(
                controller: _teacherController,
                decoration: InputDecoration(
                  labelText: 'Teacher',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Credits
              TextField(
                controller: _creditsController,
                decoration: InputDecoration(
                  labelText: 'Credits',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Semester
              TextField(
                controller: _semesterController,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Color picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Color'),
                  GestureDetector(
                    onTap: () {
                      _showColorPicker();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSubject,
                  child: const Text('Save Subject'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: GridView.count(
            crossAxisCount: 5,
            children:
                [
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.deepPurple,
                      Colors.indigo,
                      Colors.blue,
                      Colors.lightBlue,
                      Colors.cyan,
                      Colors.teal,
                      Colors.green,
                      Colors.lightGreen,
                      Colors.lime,
                      Colors.yellow,
                      Colors.amber,
                      Colors.orange,
                      Colors.deepOrange,
                      Colors.brown,
                      Colors.grey,
                      Colors.blueGrey,
                    ]
                    .map(
                      (color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}
