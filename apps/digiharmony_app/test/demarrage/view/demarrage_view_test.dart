import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_page.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_view.dart';
import 'package:digiharmony_app/pages/demarrage/widgets/barre_signature.dart';
import 'package:digiharmony_app/pages/demarrage/widgets/points_chargement.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/hydrated_storage.dart';

class _MockDemarrageBloc extends MockBloc<DemarrageEvent, DemarrageState>
    implements DemarrageBloc {}

class _MockAppDatabase extends Mock implements AppDatabase {}

Widget _harnessView({
  DemarrageState state = const DemarrageEnCours(),
  // Par défaut reduced motion : pas de boucle d'animation → pas de Timer
  // pendant. La vue reçoit directement le bloc mocké (pas besoin de fournir
  // AppDatabase : warm-up vit dans le bloc).
  bool disableAnimations = true,
  Locale locale = const Locale('en'),
}) {
  final bloc = _MockDemarrageBloc();
  whenListen<DemarrageState>(bloc, const Stream.empty(), initialState: state);

  return BlocProvider<DemarrageBloc>.value(
    value: bloc,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const DemarrageView(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const DemarrageEnCours());
    registerFallbackValue(DateTime(2026));
  });

  setUp(initMockHydratedStorage);

  group('DemarrageView — rendu nominal (SV-1->SV-10) —', () {
    testWidgets('SV-1 : logo affiché (ou errorBuilder) sans crash', (
      tester,
    ) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('SV-2 : titre DIGIHARMONY présent', (tester) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(find.text('DIGIHARMONY'), findsOneWidget);
    });

    testWidgets('SV-3 : tagline splashTagline EN présente', (tester) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(find.text('Digital well-being · Erasmus+'), findsOneWidget);
    });

    testWidgets('SV-4 : locale fr -> tagline fr', (tester) async {
      await tester.pumpWidget(_harnessView(locale: const Locale('fr')));
      await tester.pump();
      expect(
        find.text('Bien-être numérique · Erasmus+'),
        findsOneWidget,
      );
    });

    testWidgets('SV-5 : locale en -> tagline en', (tester) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(
        find.text('Digital well-being · Erasmus+'),
        findsOneWidget,
      );
    });

    testWidgets('SV-6 : BarreSignature présente', (tester) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(find.byType(BarreSignature), findsOneWidget);
    });

    testWidgets('SV-7 : PointsChargement présent', (tester) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(find.byType(PointsChargement), findsOneWidget);
    });

    testWidgets('SV-8 : Divider footer présent sans crash', (tester) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SV-9 : fond Scaffold = AppColors.backgroundDeep', (
      tester,
    ) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.backgroundDeep);
    });

    testWidgets('SV-10 : DIGIHARMONY présent en locale fr', (
      tester,
    ) async {
      await tester.pumpWidget(_harnessView(locale: const Locale('fr')));
      await tester.pump();
      expect(find.text('DIGIHARMONY'), findsOneWidget);
    });
  });

  group('DemarrageView — reduced motion (RM-2/RM-5/RM-6) —', () {
    testWidgets('RM-2 : reduced motion, écran lisible', (tester) async {
      // disableAnimations=true (défaut du harness) = reduced motion.
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(find.text('DIGIHARMONY'), findsOneWidget);
      expect(find.text('Digital well-being · Erasmus+'), findsOneWidget);
      expect(find.byType(PointsChargement), findsOneWidget);
      expect(find.byType(BarreSignature), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RM-5 : reduced motion, titre visible immédiatement', (
      tester,
    ) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump();
      expect(find.text('DIGIHARMONY'), findsOneWidget);
    });

    testWidgets('RM-6 : pump ciblé sans timeout (boucles stoppées)', (
      tester,
    ) async {
      await tester.pumpWidget(_harnessView());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('DemarragePage —', () {
    testWidgets('PAGE-1 : DemarrageBloc fourni -> DemarrageView présente', (
      tester,
    ) async {
      initMockHydratedStorage();
      final db = _MockAppDatabase();
      // Warm-up immédiat. En reduced motion, la durée minimale est 800 ms.
      // On ne pompe qu'une frame initiale : DemarrageView doit être présente.
      when(() => db.conseilDuJour(any())).thenAnswer(
        (_) async => const Conseil(id: 1, cleConseil: 'tip'),
      );
      // ignore: unnecessary_lambdas closure requise par mocktail when()
      when(() => db.observerDerniereHumeurDuJour())
          .thenAnswer((_) => const Stream<EntreeHumeur?>.empty());

      await tester.pumpWidget(
        RepositoryProvider<AppDatabase>.value(
          value: db,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: DemarragePage(),
            ),
          ),
        ),
      );
      // Juste après le premier pump : le DemarrageBloc est en cours (Drift
      // warm-up OK mais délai minimal pas encore écoulé) → DemarrageView.
      await tester.pump();
      expect(find.byType(DemarrageView), findsOneWidget);
      // Vide le délai minimal (800ms reduced) + timers AccueilBloc ensuite.
      await tester.pump(const Duration(milliseconds: 900));
      // Navigation déclenchée (DemarragePret) → AccueilPage.
      // Démontage propre pour annuler les boucles flutter_animate
      // d'AccueilPage.
      await tester.pumpWidget(const SizedBox());
      // AccueilPage peut avoir des timers jusqu'à ~1,6s : on pompe au-delà.
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
