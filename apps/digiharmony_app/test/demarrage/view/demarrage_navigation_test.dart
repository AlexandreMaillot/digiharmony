import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/accueil/accueil_page.dart';
import 'package:digiharmony_app/bienvenue/bienvenue_page.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/demarrage/view/demarrage_view.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDemarrageBloc extends MockBloc<DemarrageEvent, DemarrageState>
    implements DemarrageBloc {}

class _MockAppDatabase extends Mock implements AppDatabase {}

// La vue reçoit directement le bloc mocké : pas besoin de fournir
// BienvenueCubit (warm-up + flag vivent dans le bloc).
// AppDatabase est fourni pour couvrir la navigation vers AccueilPage.
// Reduced motion par défaut pour éviter les boucles d'animation infinies.
Widget _harnessNav({
  required Stream<DemarrageState> states,
  DemarrageState initialState = const DemarrageEnCours(),
  AppDatabase? database,
}) {
  final bloc = _MockDemarrageBloc();
  whenListen<DemarrageState>(bloc, states, initialState: initialState);

  // disableAnimations sur le builder de l'app pour que toutes les pages
  // enfants (AccueilPage, BienvenuePage...) héritent aussi du flag.
  Widget app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: BlocProvider<DemarrageBloc>.value(
      value: bloc,
      child: const DemarrageView(),
    ),
  );

  if (database != null) {
    app = RepositoryProvider<AppDatabase>.value(
      value: database,
      child: app,
    );
  }

  return app;
}

void main() {
  late _MockAppDatabase database;

  setUpAll(() {
    registerFallbackValue(const DemarrageEnCours());
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    database = _MockAppDatabase();
    when(() => database.conseilDuJour(any()))
        .thenAnswer((_) async => const Conseil(id: 1, cleConseil: 'tipDay01'));
    when(() => database.observerDerniereHumeurDuJour())
        .thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
  });

  group('DemarrageView — navigation (NAV-1->NAV-5) —', () {
    testWidgets(
      'NAV-1 : PretPourBienvenue -> pushReplacement vers BienvenuePage',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePretPourBienvenue()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BienvenuePage), findsOneWidget);
        expect(find.byType(DemarrageView), findsNothing);
      },
    );

    testWidgets(
      'NAV-2 : PretPourAccueil -> pushReplacement vers AccueilPage',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePretPourAccueil()),
            database: database,
          ),
        );
        // AccueilPage porte des animations flutter_animate en boucle :
        // pumpAndSettle() timeout. On pompe assez de frames pour que la
        // navigation soit traitée. On vide aussi le timer asynchrone de
        // AccueilBloc (conseilDuJour) avant démontage.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(AccueilPage), findsOneWidget);
        expect(find.byType(DemarrageView), findsNothing);
        // Vide les timers pendants (AccueilBloc async init).
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets(
      'NAV-3 : DemarrageErreur versBienvenue=true -> Bienvenue sans crash',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(
              const DemarrageErreur(versBienvenue: true),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BienvenuePage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'NAV-4 : après navigation, Demarrage plus dans la pile (no back)',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePretPourAccueil()),
            database: database,
          ),
        );
        // AccueilPage porte des animations flutter_animate en boucle :
        // pumpAndSettle() timeout. Pompage fini suffisant pour la navigation.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(AccueilPage), findsOneWidget);
        // pushReplacement : la pile ne contient plus DemarrageView.
        expect(find.byType(DemarrageView), findsNothing);
        // Vide les timers pendants (AccueilBloc async init).
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets(
      'NAV-5 : DemarrageEnCours -> aucune navigation déclenchée',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: const Stream.empty(),
          ),
        );
        await tester.pump();
        expect(find.byType(DemarrageView), findsOneWidget);
        expect(find.byType(BienvenuePage), findsNothing);
        expect(find.byType(AccueilPage), findsNothing);
      },
    );
  });
}
