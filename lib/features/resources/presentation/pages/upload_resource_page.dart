import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/bloc/base_state.dart';
import '../../../../core/bloc/view_state.dart';
import '../../domain/entities/file_resource.dart';
import '../bloc/resource_bloc.dart';
import '../bloc/resource_event.dart';

class UploadResourcePage extends StatefulWidget {
  final String userId;
  final String? subjectId;

  const UploadResourcePage({super.key, required this.userId, this.subjectId});

  @override
  State<UploadResourcePage> createState() => _UploadResourcePageState();
}

class _UploadResourcePageState extends State<UploadResourcePage> {
  File? _file;
  bool _favorite = false;

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles();
    if (res?.files.single.path == null) return;

    setState(() => _file = File(res!.files.single.path!));
  }

  void _upload() {
    if (_file == null) return;

    final file = _file!;
    final name = file.path.split('/').last;
    final ext = name.split('.').last;

    context.read<ResourceBloc>().add(
      UploadResourceEvent(
        resource: FileResource(
          id: const Uuid().v4(),
          userId: widget.userId,
          subjectId: widget.subjectId,
          name: name,
          type: ext,
          url: '',
          size: file.lengthSync(),
          isFavorite: _favorite,
          createdAt: DateTime.now(),
        ),
        file: file,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resource'), centerTitle: true),
      body: BlocConsumer<ResourceBloc, BaseState<List<FileResource>>>(
        listener: (context, state) {
          final viewState = state.viewState;

          if (viewState is ViewFailure<List<FileResource>>) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewState.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (viewState is ViewSuccess<List<FileResource>>) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final viewState = state.viewState;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// STEP 1
                const _StepHeader(step: '1', title: 'Choose file'),
                const SizedBox(height: 10),
                _FilePickerTile(file: _file, onTap: _pickFile),

                const SizedBox(height: 24),

                /// STEP 2
                const _StepHeader(step: '2', title: 'Options'),
                const SizedBox(height: 10),
                _FavoriteTile(
                  value: _favorite,
                  onChanged: (v) => setState(() => _favorite = v),
                ),

                const SizedBox(height: 20),

                /// ✅ PROGRESS (SAFE)
                if (viewState is ViewLoading<List<FileResource>> &&
                    viewState.progress != null)
                  _UploadProgress(progress: viewState.progress!),

                const Spacer(),

                ElevatedButton(
                  onPressed: _file == null || viewState is ViewLoading
                      ? null
                      : _upload,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Upload Resource',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String step;
  final String title;

  const _StepHeader({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FilePickerTile extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const _FilePickerTile({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = file != null;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.insert_drive_file : Icons.upload_file,
              size: 34,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                selected ? file!.path.split('/').last : 'Tap to select a file',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FavoriteTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: const Text('Mark as favorite'),
      subtitle: const Text('Quick access from favorites'),
      secondary: Icon(
        value ? Icons.star_rounded : Icons.star_border_rounded,
        color: Colors.amber,
      ),
    );
  }
}

class _UploadProgress extends StatelessWidget {
  final double progress;

  const _UploadProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 8),
        Text(
          '$percent% uploaded',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
