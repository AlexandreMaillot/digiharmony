import 'package:digiharmony_app/bulles/view/bulles_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('App', () {
    testWidgets('renders BullesPage as home', (tester) async {
      // Le hub anime ses bulles en boucle (shimmer + flottement). On force le
      // mode « animations reduites » pour exercer le chemin sans timers et
      // garder un widget test deterministe (cf. reduceMotion dans BullesView).
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await tester.pumpApp(const BullesPage());
      await tester.pump();

      expect(find.byType(BullesPage), findsOneWidget);
      // Les 4 categories sont rendues (labels resolus depuis l'ARB).
      expect(find.byType(InkResponse), findsNWidgets(4));
    });
  });
}
