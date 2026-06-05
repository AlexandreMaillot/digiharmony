import 'package:digiharmony_app/accueil/accueil_page.dart';
import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/bienvenue/bienvenue_page.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(void Function(BuildContext) onTap) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => onTap(context),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('AppRouter', () {
    testWidgets('RT-2 : versBienvenue remplace par BienvenuePage', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(AppRouter.versBienvenue));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(BienvenuePage), findsOneWidget);
    });

    testWidgets('RT-1/RT-4 : versAccueil remplace par AccueilPage', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(AppRouter.versAccueil));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(AccueilPage), findsOneWidget);
    });

    testWidgets('RT-3 : pushReplacement -> écran source non réaffiché', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(AppRouter.versAccueil));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('go'), findsNothing);
      expect(find.byType(AccueilPage), findsOneWidget);
    });
  });
}
