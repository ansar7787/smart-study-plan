import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/knowledge/presentation/widgets/inline_ai_suggestions.dart';

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
      RunAiActionEvent(action: action, input: widget.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: BlocBuilder<KnowledgeBloc, KnowledgeState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              InlineAiSuggestions(onSelect: _run),
              const SizedBox(height: 20),

              if (state is AiActionRunning)
                const Center(child: CircularProgressIndicator()),

              if (state is AiActionCompleted)
                AiResultView(result: state.result),
            ],
          );
        },
      ),
    );
  }
}
