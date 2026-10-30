import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';
import '../services/settings_store.dart';
import '../theme.dart';
import '../widgets/exercise_figure.dart';
import 'complete_screen.dart';

/// The workout itself: one full screen per exercise, swipe or tap Next
/// to move on.
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, required this.store});

  final SettingsStore store;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final List<Exercise> _plan = widget.store.plan;
  late final Map<String, int> _targets = {
    for (final e in _plan) e.id: widget.store.repsFor(e),
  };
  final Map<String, int> _done = {};
  final PageController _pages = PageController();
  final Stopwatch _clock = Stopwatch()..start();
  int _index = 0;

  bool get _isLast => _index == _plan.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int i) => _pages.animateToPage(
        i,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _goTo(_index + 1);
    }
  }

  void _finish() {
    _clock.stop();
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => CompleteScreen(
          exercises: _plan.length,
          totalReps: _targets.values.fold(0, (a, b) => a + b),
          duration: _clock.elapsed,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _countRep(Exercise e) {
    final target = _targets[e.id]!;
    final done = _done[e.id] ?? 0;
    if (done >= target) return;
    setState(() => _done[e.id] = done + 1);

    if (done + 1 == target) {
      HapticFeedback.mediumImpact();
      // Short pause so the tick registers, then move on automatically.
      final page = _index;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _index == page) _next();
      });
    } else {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              index: _index,
              count: _plan.length,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _plan.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final e = _plan[i];
                  return _ExercisePage(
                    exercise: e,
                    target: _targets[e.id]!,
                    done: _done[e.id] ?? 0,
                    onCount: () => _countRep(e),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _index == 0
                        ? const SizedBox(width: 0, height: 60)
                        : Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  side: BorderSide(color: muted(context, 0.2)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () => _goTo(_index - 1),
                                child: const Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(_isLast ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.index,
    required this.count,
    required this.onClose,
  });

  final int index;
  final int count;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'End workout',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClose,
              ),
              const Spacer(),
              Text(
                '${two(index + 1)} / ${two(count)}',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 1.5,
                  color: muted(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                for (var i = 0; i < count; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      height: 3,
                      margin: EdgeInsets.only(right: i == count - 1 ? 0 : 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= index
                            ? Theme.of(context).colorScheme.onSurface
                            : muted(context, 0.12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExercisePage extends StatelessWidget {
  const _ExercisePage({
    required this.exercise,
    required this.target,
    required this.done,
    required this.onCount,
  });

  final Exercise exercise;
  final int target;
  final int done;
  final VoidCallback onCount;

  @override
  Widget build(BuildContext context) {
    final remaining = target - done;
    final complete = remaining == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ExerciseFigure(exercise: exercise),
                ),
              ),
            ),
          ),
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.cue,
            style: TextStyle(fontSize: 15, color: muted(context), height: 1.4),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCount,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.85, end: 1.0).animate(anim),
                            child: child,
                          ),
                        ),
                        child: complete
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey('done'),
                                size: 84,
                              )
                            : Text(
                                '$remaining',
                                key: ValueKey(remaining),
                                style: const TextStyle(
                                  fontSize: 84,
                                  fontWeight: FontWeight.w200,
                                  height: 1,
                                  fontFeatures: [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        complete
                            ? 'done'
                            : done == 0
                                ? 'reps  ·  tap to count'
                                : 'reps to go',
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 1,
                          color: muted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
