import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../services/settings_store.dart';
import '../theme.dart';
import '../widgets/exercise_figure.dart';
import 'settings_screen.dart';
import 'workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final plan = store.plan;
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'REP FLOW',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                          color: muted(context),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(store: store),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Full body',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w300,
                      height: 1.05,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${plan.length} exercises  ·  ${store.totalReps} reps',
                    style: TextStyle(fontSize: 15, color: muted(context)),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView.separated(
                      itemCount: exercises.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) =>
                          _ExerciseRow(exercise: exercises[i], store: store),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: plan.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 450),
                                pageBuilder: (_, __, ___) =>
                                    WorkoutScreen(store: store),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(opacity: anim, child: child),
                              ),
                            ),
                    child: Text(plan.isEmpty ? 'No exercises set' : 'Start'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise, required this.store});

  final Exercise exercise;
  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    final reps = store.repsFor(exercise);
    final skipped = reps == 0;
    return Opacity(
      opacity: skipped ? 0.35 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ExerciseFigure(
                exercise: exercise,
                animate: false,
                showFloor: false,
                strokeScale: 1.6,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            Text(
              skipped ? 'skip' : '$reps',
              style: TextStyle(
                fontSize: 17,
                color: muted(context, 0.6),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
