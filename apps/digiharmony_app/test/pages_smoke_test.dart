import 'package:digiharmony_app/pages/detox/view/detox_config_page.dart';
import 'package:digiharmony_app/pages/sens/view/sens_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/helpers.dart';

void main() {
  // Smoke tests for the timer-free pages. The timer-driven pages (Breathing,
  // Stretch, DetoxPlayer) are covered by their bloc tests; pumping them in a
  // widget test leaves pending periodic timers/animations.
  group('pages render without throwing', () {
    testWidgets('SensPage', (tester) async {
      await tester.pumpApp(const SensPage());
      await tester.pump();
      expect(find.byType(SensView), findsOneWidget);
    });

    testWidgets('DetoxConfigPage', (tester) async {
      await tester.pumpApp(const DetoxConfigPage());
      await tester.pump();
      expect(find.byType(DetoxConfigView), findsOneWidget);
    });
  });
}
