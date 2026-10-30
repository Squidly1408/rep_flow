import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';
import '../services/settings_store.dart';
import '../theme.dart';
import '../widgets/exercise_figure.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});

  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reps per exercise')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              'Set how many reps you do of each exercise. '
              'Set one to 0 to skip it.',
              style: TextStyle(fontSize: 14, color: muted(context), height: 1.4),
            ),
            const SizedBox(height: 16),
            for (final e in exercises) ...[
              _SettingRow(exercise: e, store: store),
              const Divider(),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: store.resetDefaults,
                child: const Text('Reset to defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.exercise, required this.store});

  final Exercise exercise;
  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    final reps = store.repsFor(exercise);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: ExerciseFigure(
              exercise: exercise,
              animate: false,
              showFloor: false,
              strokeScale: 1.6,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  reps == 0 ? 'Skipped' : 'Default ${exercise.defaultReps}',
                  style: TextStyle(fontSize: 13, color: muted(context)),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: reps > 0,
            onStep: () => store.setReps(exercise, store.repsFor(exercise) - 1),
          ),
          SizedBox(
            width: 52,
            child: Text(
              '$reps',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: reps < SettingsStore.maxReps,
            onStep: () => store.setReps(exercise, store.repsFor(exercise) + 1),
          ),
        ],
      ),
    );
  }
}

/// Round +/- button. Tap for one step, hold to keep stepping.
class _StepButton extends StatefulWidget {
  const _StepButton({
    required this.icon,
    required this.onStep,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onStep;
  final bool enabled;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  Timer? _repeat;

  void _start() {
    _repeat?.cancel();
    _repeat = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (!mounted || !widget.enabled) return _stop();
      widget.onStep();
    });
  }

  void _stop() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              widget.onStep();
            }
          : null,
      onLongPressStart: enabled ? (_) => _start() : null,
      onLongPressEnd: (_) => _stop(),
      onLongPressCancel: _stop,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.3,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: muted(context, 0.25)),
          ),
          child: Icon(widget.icon, size: 20),
        ),
      ),
    );
  }
}
