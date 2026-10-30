import 'package:flutter_test/flutter_test.dart';
import 'package:rep_flow/main.dart';
import 'package:rep_flow/models/exercise.dart';
import 'package:rep_flow/services/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('home lists the routine and starts the workout', (tester) async {
    final store = SettingsStore();
    await store.load();
    await tester.pumpWidget(RepFlowApp(store: store));

    expect(find.text('Full body'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text(exercises.first.name), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  test('reps are stored per exercise and 0 skips it', () async {
    final store = SettingsStore();
    await store.load();

    store.setReps(exercises[1], 0);
    store.setReps(exercises[2], 25);

    expect(store.plan.contains(exercises[1]), isFalse);
    expect(store.repsFor(exercises[2]), 25);

    final reloaded = SettingsStore();
    await reloaded.load();
    expect(reloaded.repsFor(exercises[2]), 25);
  });
}
