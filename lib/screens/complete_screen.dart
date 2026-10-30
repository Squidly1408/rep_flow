import 'package:flutter/material.dart';

import '../theme.dart';

class CompleteScreen extends StatelessWidget {
  const CompleteScreen({
    super.key,
    required this.exercises,
    required this.totalReps,
    required this.duration,
  });

  final int exercises;
  final int totalReps;
  final Duration duration;

  String get _time {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, alignment: Alignment.centerLeft, child: child),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Workout\ncomplete',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w300,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  _Stat(value: '$exercises', label: 'exercises'),
                  _Stat(value: '$totalReps', label: 'reps'),
                  _Stat(value: _time, label: 'time'),
                ],
              ),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(label, style: TextStyle(fontSize: 13, color: muted(context))),
        ],
      ),
    );
  }
}
