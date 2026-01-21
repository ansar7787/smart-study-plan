import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_study_plan/features/knowledge/presentation/extensions/knowledge_type_ui.dart';
import '../../domain/enums/knowledge_type.dart';

class EmptyKnowledgeView extends StatelessWidget {
  final KnowledgeType type;

  const EmptyKnowledgeView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 72.r, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No ${type.label.toLowerCase()} yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              'Tap + to add your first one',
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
