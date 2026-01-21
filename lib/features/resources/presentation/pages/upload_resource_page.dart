import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/file_resource.dart';
import '../bloc/resource_bloc.dart';
import '../bloc/resource_event.dart';
import '../bloc/resource_state.dart';
import '../../../subjects/presentation/bloc/subject_bloc.dart';
import '../../../subjects/presentation/bloc/subject_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.subjectId;
  }

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
          subjectId: _selectedSubjectId,
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
      body: BlocConsumer<ResourceBloc, ResourceState>(
        listener: (context, state) {
          if (state.status == ResourceStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state.status == ResourceStatus.success && _file != null) {
            // Check if we actually uploaded something (_file != null means we were in the process)
            // Ideally we'd track "submitting" state locally or check previous state.
            // But since this page is for uploading, navigating back on success is generally desired
            // IF we were loading before.
            // Simplified: Just pop on success if we have a file selected (implies we tried).
            // Actually, better to check if we were loading?
            // Let's rely on the fact that we stay here until success.
            Navigator.pop(context);
          }
        },
        listenWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          final isLoading = state.status == ResourceStatus.loading;
          final progress = state.uploadProgress;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// STORAGE WARNING
                if (state.totalStorageUsed > 225.0 * 1024 * 1024)
                  Container(
                    margin: EdgeInsets.only(bottom: 20.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Storage limit nearly reached. Consider deleting some files.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.orange.shade900
                                  : Colors.orange.shade200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                /// STEP 1
                _StepHeader(step: '1', title: 'Choose file'),
                SizedBox(height: 10.h),
                _FilePickerTile(file: _file, onTap: _pickFile),

                SizedBox(height: 24.h),

                /// STEP 2
                _StepHeader(step: '2', title: 'Options'),
                SizedBox(height: 10.h),
                _FavoriteTile(
                  value: _favorite,
                  onChanged: (v) => setState(() => _favorite = v),
                ),

                SizedBox(height: 24.h),

                /// STEP 3
                _StepHeader(step: '3', title: 'Select Subject'),
                SizedBox(height: 10.h),
                BlocBuilder<SubjectBloc, SubjectState>(
                  builder: (context, subjectState) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select a subject'),
                          value: _selectedSubjectId,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('General / No Subject'),
                            ),
                            ...subjectState.subjects.map((s) {
                              return DropdownMenuItem<String>(
                                value: s.id,
                                child: Text(s.name),
                              );
                            }),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedSubjectId = v),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 32.h),

                /// ✅ PROGRESS (SAFE)
                if (isLoading) _UploadProgress(progress: progress),

                SizedBox(height: 48.h),

                ElevatedButton(
                  onPressed: _file == null || isLoading ? null : _upload,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    isLoading ? 'Uploading...' : 'Upload Resource',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
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
          radius: 14.r,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            step,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
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
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.insert_drive_file : Icons.upload_file,
              size: 34.sp,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                selected ? file!.path.split('/').last : 'Tap to select a file',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uploading...',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8.h,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 4.h),
        Center(
          child: Text(
            'Keep the app open until finished',
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
