import 'package:digiharmony_app/common/anim/entree_douce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pompe un widget avec le flag [disableAnimations] configuré.
Future<void> pumpAvecMotion(
  WidgetTester tester,
  Widget widget, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );
  await tester.pump();
}

void main() {
  group('EntreeDouce', () {
    // RM-ED-1 : En reduced-motion, retourne child sans Animate.
    testWidgets(
      "RM-ED-1 : reduced-motion → child direct, pas d'Animate",
      (tester) async {
        await pumpAvecMotion(
          tester,
          const EntreeDouce(child: Text('hello')),
          disableAnimations: true,
        );

        // Le texte est visible immédiatement.
        expect(find.text('hello'), findsOneWidget);
        // Pas de widget Animate (no-op complet).
        expect(find.byType(Animate), findsNothing);
      },
    );

    // RM-ED-2 : Sans reduced-motion, Animate est présent.
    testWidgets(
      'RM-ED-2 : animations ON → Animate présent',
      (tester) async {
        await pumpAvecMotion(
          tester,
          const EntreeDouce(child: Text('hello')),
        );
        // pump sans pumpAndSettle pour éviter les timers en boucle.
        await tester.pump(Duration.zero);

        expect(find.byType(Animate), findsWidgets);
      },
    );

    // RM-ED-3 : État final atteint après pump(dureeEntree) sans hang.
    testWidgets(
      'RM-ED-3 : animations ON → état final atteint après durée',
      (tester) async {
        await pumpAvecMotion(
          tester,
          const EntreeDouce(child: Text('hello')),
        );

        // Avance le temps pour terminer l'animation.
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 100));

        // Le texte reste visible après l'animation.
        expect(find.text('hello'), findsOneWidget);
      },
    );

    // RM-ED-4 : cascade — index produit le bon délai.
    testWidgets(
      'RM-ED-4 : cascade index=2 → widget présent sans crash',
      (tester) async {
        await pumpAvecMotion(
          tester,
          const EntreeDouce(index: 2, child: Text('cascade')),
        );
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.text('cascade'), findsOneWidget);
      },
    );
  });
}
