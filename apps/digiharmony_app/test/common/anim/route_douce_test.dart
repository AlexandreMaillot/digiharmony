import 'package:digiharmony_app/common/anim/route_douce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Écran initial de test pour naviguer depuis.
class _EcranDepart extends StatelessWidget {
  const _EcranDepart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => Navigator.of(context)
            .push(routeDouce<void>(const _EcranCible())),
        child: const Text('aller'),
      ),
    );
  }
}

/// Écran cible de navigation.
class _EcranCible extends StatelessWidget {
  const _EcranCible();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('cible'));
  }
}

void main() {
  group('routeDouce', () {
    // RM-RD-1 : En reduced-motion, la navigation se fait sans FadeTransition.
    testWidgets(
      'RM-RD-1 : reduced-motion → navigation sans FadeTransition',
      (tester) async {
        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MaterialApp(home: _EcranDepart()),
          ),
        );
        await tester.pump();

        // Navigue vers la cible.
        await tester.tap(find.text('aller'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // La cible est affichée (navigation réussie).
        expect(find.text('cible'), findsOneWidget);
        // Pas de FadeTransition (transition désactivée).
        expect(find.byType(FadeTransition), findsNothing);
      },
    );

    // RM-RD-2 : Sans reduced-motion, la navigation utilise FadeTransition.
    testWidgets(
      'RM-RD-2 : animations ON → FadeTransition présent pendant transition',
      (tester) async {
        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(),
            child: MaterialApp(home: _EcranDepart()),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('aller'));
        // Pompe une frame pour démarrer la transition.
        await tester.pump(Duration.zero);

        // FadeTransition présent pendant l'animation.
        expect(find.byType(FadeTransition), findsWidgets);

        // Finit la transition.
        await tester.pump(const Duration(milliseconds: 400));
        // La cible est visible.
        expect(find.text('cible'), findsOneWidget);
      },
    );

    // RM-RD-3 : routeDouce sans paramètre settings fonctionne.
    test(
      'RM-RD-3 : routeDouce crée une Route<void> sans settings',
      () {
        final route = routeDouce<void>(const _EcranCible());
        expect(route, isA<PageRouteBuilder<void>>());
      },
    );

    // RM-RD-4 : routeDouce avec settings transmet les settings.
    test(
      'RM-RD-4 : routeDouce transmet RouteSettings',
      () {
        const settings = RouteSettings(name: '/cible');
        final route = routeDouce<void>(
          const _EcranCible(),
          settings: settings,
        );
        expect(route.settings.name, equals('/cible'));
      },
    );
  });
}
