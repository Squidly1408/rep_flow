import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';

/// Holds the rep count for each exercise and persists it on the device.
/// A count of 0 means the exercise is skipped.
class SettingsStore extends ChangeNotifier {
  static const int maxReps = 200;

  final Map<String, int> _reps = {
    for (final e in exercises) e.id: e.defaultReps,
  };
  SharedPreferences? _prefs;

  static String _key(String id) => 'reps_$id';

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      for (final e in exercises) {
        final saved = _prefs!.getInt(_key(e.id));
        if (saved != null) _reps[e.id] = saved.clamp(0, maxReps);
      }
    } catch (_) {
      // Storage unavailable — fall back to defaults for this session.
    }
    notifyListeners();
  }

  int repsFor(Exercise e) => _reps[e.id] ?? e.defaultReps;

  void setReps(Exercise e, int value) {
    final v = value.clamp(0, maxReps);
    if (_reps[e.id] == v) return;
    _reps[e.id] = v;
    notifyListeners();
    _prefs?.setInt(_key(e.id), v);
  }

  void resetDefaults() {
    for (final e in exercises) {
      _reps[e.id] = e.defaultReps;
      _prefs?.remove(_key(e.id));
    }
    notifyListeners();
  }

  /// Exercises that will be performed, in order (skips anything set to 0).
  List<Exercise> get plan =>
      exercises.where((e) => repsFor(e) > 0).toList(growable: false);

  int get totalReps => plan.fold(0, (sum, e) => sum + repsFor(e));
}
