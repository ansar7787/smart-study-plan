import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';

class SessionTimerPage extends StatefulWidget {
  final StudySession session;

  const SessionTimerPage({super.key, required this.session});

  @override
  State<SessionTimerPage> createState() => _SessionTimerPageState();
}

class _SessionTimerPageState extends State<SessionTimerPage> {
  // Timer state
  late Timer _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  // Session duration (if set)
  int get _targetDurationSeconds =>
      widget.session.endTime.difference(widget.session.startTime).inSeconds;

  @override
  void initState() {
    super.initState();
    // Don't auto-start, let user click start
    // If we wanted to "resume" logic, we'd check saved preferences here.
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  void _finishSession() {
    if (_isRunning) {
      _timer.cancel();
    }

    final updatedSession = widget.session.copyWith(
      actualDuration: _secondsElapsed,
      isCompleted: true,
      updatedAt: DateTime.now(),
    );

    context.read<PlannerBloc>().add(UpdateSessionEvent(updatedSession));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  Future<void> _showQuitDialog() async {
    // If timer wasn't running and no progress, just pop
    if (!_isRunning && _secondsElapsed == 0) {
      Navigator.pop(context);
      return;
    }

    if (_isRunning && !_isPaused) {
      _pauseTimer();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: Text(
          'You have focused for ${_formatTime(_secondsElapsed)}.\nSave your progress?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close page (Discard)
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_isRunning) _resumeTimer(); // Cancel dialog = resume
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _finishSession(); // Save & Close page
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progress = _targetDurationSeconds > 0
        ? _secondsElapsed / _targetDurationSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Session: ${widget.session.title}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showQuitDialog,
        ),
        actions: [
          if (_secondsElapsed > 0)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _finishSession,
              tooltip: 'Finish & Save',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Timer Display
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 20,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isPaused ? Colors.orange : colorScheme.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_secondsElapsed),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning
                          ? (_isPaused ? 'Paused' : 'Focusing...')
                          : 'Ready to start?',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Session Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    widget.session.description.isNotEmpty
                        ? widget.session.description
                        : 'No description',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_targetDurationSeconds > 0)
                    Text(
                      'Target: ${_formatTime(_targetDurationSeconds)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            // Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause
                  FloatingActionButton.large(
                    heroTag: 'control_timer',
                    onPressed: _isRunning
                        ? (_isPaused ? _resumeTimer : _pauseTimer)
                        : _startTimer,
                    backgroundColor: !_isRunning || _isPaused
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor: !_isRunning || _isPaused
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    child: Icon(
                      !_isRunning || _isPaused ? Icons.play_arrow : Icons.pause,
                      size: 48,
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Stop/Finish
                  FloatingActionButton.large(
                    heroTag: 'finish_session',
                    onPressed: () {
                      if (_secondsElapsed == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Start the timer first!'),
                          ),
                        );
                        return;
                      }
                      _finishSession();
                    },
                    backgroundColor: _secondsElapsed > 0
                        ? Colors.green
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    tooltip: 'Finish Session',
                    child: const Icon(Icons.check, size: 48),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
