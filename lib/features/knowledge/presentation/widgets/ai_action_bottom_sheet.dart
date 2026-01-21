import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/knowledge/presentation/widgets/inline_ai_suggestions.dart';
import 'package:smart_study_plan/config/ai/ai_config.dart';

import '../bloc/knowledge_bloc.dart';
import '../bloc/knowledge_event.dart';
import '../bloc/knowledge_state.dart';

import '../../domain/enums/ai_action_type.dart';
import 'ai_result_view.dart';

class AiActionBottomSheet extends StatefulWidget {
  final String content;
  final String userId;
  final AiActionType? initialAction;

  const AiActionBottomSheet({
    super.key,
    required this.content,
    required this.userId,
    this.initialAction,
  });

  @override
  State<AiActionBottomSheet> createState() => _AiActionBottomSheetState();
}

class _AiActionBottomSheetState extends State<AiActionBottomSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.initialAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _run(widget.initialAction!);
      });
    }
  }

  void _run(AiActionType action) {
    context.read<KnowledgeBloc>().add(
      RunAiActionEvent(
        userId: widget.userId,
        action: action,
        input: widget.content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: SingleChildScrollView(
        child: BlocBuilder<KnowledgeBloc, KnowledgeState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),

                InlineAiSuggestions(onSelect: _run),
                SizedBox(height: 20.h),

                if (AiConfig.geminiKey.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Gemini API Key is missing. AI features will not work.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (state.aiStatus == AiStatus.loading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                if (state.aiStatus == AiStatus.failure)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      state.errorMessage ?? 'AI Action failed',
                      style: TextStyle(color: Colors.red, fontSize: 13.sp),
                    ),
                  ),

                if (state.aiStatus == AiStatus.success &&
                    state.aiResult != null)
                  AiResultView(result: state.aiResult!),
              ],
            );
          },
        ),
      ),
    );
  }
}
