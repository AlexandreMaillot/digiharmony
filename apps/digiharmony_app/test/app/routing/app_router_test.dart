import 'package:digiharmony_app/accueil/accueil_page.dart';
import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/bienvenue/bienvenue_page.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late _MockAppDatabase database;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    database = _MockAppDatabase();
    when(() => database.conseilDuJour(any()))
        .thenAnswer((_) async => const Conseil(id: 1, cleConseil: 'tipDay01'));
    when(() => database.observerDerniereHumeurDuJour())
        .thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
    TestWidgetsFlutterBinding.instance.platformDispatcher
            .accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });

  tearDown(() {
    TestWidgetsFlutterBinding
        .instance.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });

  Widget harness(void Function(BuildContext) onTap) {
    return RepositoryProvider<AppDatabase>.value(
      value: database,
      child: MaterialApp(
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
      ),
    );
  }

  group('AppRouter', () {
    testWidgets('RT-2 : versBienvenue remplace par BienvenuePage',
        (tester) async {
      await tester.pumpWidget(harness(AppRouter.versBienvenue));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(BienvenuePage), findsOneWidget);
    });

    testWidgets('RT-1/RT-4 : versAccueil remplace par AccueilPage',
        (tester) async {
      await tester.pumpWidget(harness(AppRouter.versAccueil));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(AccueilPage), findsOneWidget);
    });

    testWidgets('RT-3 : pushReplacement -> écran source non réaffiché',
        (tester) async {
      await tester.pumpWidget(harness(AppRouter.versAccueil));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('go'), findsNothing);
      expect(find.byType(AccueilPage), findsOneWidget);
    });
  });
}
