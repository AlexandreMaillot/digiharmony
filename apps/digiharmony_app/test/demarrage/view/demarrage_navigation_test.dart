import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_page.dart';
import 'package:digiharmony_app/pages/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_view.dart';
import 'package:digiharmony_app/pages/soutien/bloc/soutien_bloc.dart';
import 'package:digiharmony_app/pages/soutien/views/soutien_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/hydrated_storage.dart';

class _MockDemarrageBloc extends MockBloc<DemarrageEvent, DemarrageState>
    implements DemarrageBloc {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockSoutienBloc extends MockBloc<SoutienEvent, SoutienState>
    implements SoutienBloc {}

/// Construit l'arbre de test pour DemarrageView.
///
/// [soutienBloc] : fourni explicitement pour les tests qui contrôlent l'état
/// anti-relance ; si null, un SoutienBloc réel est créé (état initial false).
Widget _harnessNav({
  required Stream<DemarrageState> states,
  required AppDatabase database,
  DemarrageState initialState = const DemarrageEnCours(),
  SoutienBloc? soutienBloc,
}) {
  final demarrageBloc = _MockDemarrageBloc();
  whenListen<DemarrageState>(
    demarrageBloc,
    states,
    initialState: initialState,
  );

  final soutien = soutienBloc ?? SoutienBloc();

  // disableAnimations pour éviter les boucles d'animation infinies.
  return RepositoryProvider<AppDatabase>.value(
    value: database,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<DemarrageBloc>.value(value: demarrageBloc),
        BlocProvider<SoutienBloc>.value(value: soutien),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const DemarrageView(),
      ),
    ),
  );
}

void main() {
  late _MockAppDatabase database;

  setUpAll(() {
    registerFallbackValue(const DemarrageEnCours());
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(const SoutienMontre());
    registerFallbackValue(const SoutienReinitialise());
  });

  setUp(() {
    initMockHydratedStorage();

    database = _MockAppDatabase();
    when(
      () => database.conseilDuJour(any()),
    ).thenAnswer((_) async => const Conseil(
        id: 1,
        cleConseil: 'tipDay01',
        typeCarte: 'rappel',
        accentChrome: 'primary',
        ordre: 1,
      ));
    when(
      () => database.observerDerniereHumeurDuJour(),
    ).thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
    // Défaut : compteur = 0 (aucun déclenchement soutien).
    when(
      () => database.compterSaisiesNegativesConsecutives(),
    ).thenAnswer((_) async => 0);
  });

  group('DemarrageView — navigation (NAV-1->NAV-4) —', () {
    testWidgets(
      'NAV-1 : DemarragePret -> pushReplacement vers AccueilPage',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePret()),
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
      'NAV-2 : DemarrageErreur -> AccueilPage sans crash',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarrageErreur()),
            database: database,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(AccueilPage), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Vide les timers pendants.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets(
      'NAV-3 : après navigation, Demarrage plus dans la pile (no back)',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePret()),
            database: database,
          ),
        );
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
      'NAV-4 : DemarrageEnCours -> aucune navigation déclenchée',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: const Stream.empty(),
            database: database,
          ),
        );
        await tester.pump();
        expect(find.byType(DemarrageView), findsOneWidget);
        expect(find.byType(AccueilPage), findsNothing);
      },
    );
  });

  group(
    'DemarrageView — déclenchement soutien post-splash (NAV-S-1..4) —',
    () {
      // Ces tests prouvent le comportement runtime du hook soutien.
      // Ils ÉCHOUAIENT avec le code original (pushReplacement avant évaluation)
      // et PASSENT avec le correctif (évaluation avant pushReplacement).

      testWidgets(
        'NAV-S-1 : compteur >= 7 et !dejaMontre -> SoutienMontre emis et'
        ' SoutienPage poussee',
        (tester) async {
          when(
            () => database.compterSaisiesNegativesConsecutives(),
          ).thenAnswer((_) async => 7);

          // MockBloc avec état initial false : on vérifiera que
          // add(SoutienMontre) est appelé et que SoutienPage est poussée.
          final soutienBloc = _MockSoutienBloc();
          whenListen<SoutienState>(
            soutienBloc,
            const Stream<SoutienState>.empty(),
            initialState: const SoutienState(),
          );

          await tester.pumpWidget(
            _harnessNav(
              states: Stream.value(const DemarragePret()),
              database: database,
              soutienBloc: soutienBloc,
            ),
          );

          // Séquence de pompes pour résoudre la chaîne async :
          // 1. BlocListener reçoit l'état, démarre
          //    _versAccueilPuisEvaluerSoutien.
          await tester.pump();
          // 2. Microtask : compterSaisiesNegativesConsecutives() résolue.
          await tester.pump();
          // 3–5. Frames de navigation (pushReplacement + push).
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 500));

          // SoutienMontre doit avoir été émis (marquage à l'affichage).
          verify(() => soutienBloc.add(const SoutienMontre())).called(1);
          // SoutienPage doit être empilée au-dessus de AccueilPage.
          expect(find.byType(SoutienPage), findsOneWidget);

          // Démonter pour vider les timers d'animation.
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
        },
      );

      testWidgets(
        'NAV-S-2 : compteur < 7 -> pas de SoutienPage',
        (tester) async {
          // compteur = 0 (défaut configuré dans setUp)
          await tester.pumpWidget(
            _harnessNav(
              states: Stream.value(const DemarragePret()),
              database: database,
            ),
          );

          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.byType(SoutienPage), findsNothing);
          expect(find.byType(AccueilPage), findsOneWidget);

          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
        },
      );

      testWidgets(
        'NAV-S-3 : compteur >= 7 et dejaMontre == true -> pas de'
        ' re-déclenchement',
        (tester) async {
          when(
            () => database.compterSaisiesNegativesConsecutives(),
          ).thenAnswer((_) async => 7);

          // MockBloc avec état initial "montré" — pas d'event processing réel.
          final soutienBloc = _MockSoutienBloc();
          whenListen<SoutienState>(
            soutienBloc,
            const Stream<SoutienState>.empty(),
            initialState: const SoutienState(
              dejaMontrePourEpisodeEnCours: true,
            ),
          );

          await tester.pumpWidget(
            _harnessNav(
              states: Stream.value(const DemarragePret()),
              database: database,
              soutienBloc: soutienBloc,
            ),
          );

          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // Pas de SoutienPage : anti-relance actif.
          expect(find.byType(SoutienPage), findsNothing);
          expect(find.byType(AccueilPage), findsOneWidget);
          // Aucun SoutienMontre émis.
          verifyNever(
            () => soutienBloc.add(const SoutienMontre()),
          );

          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
        },
      );

      testWidgets(
        'NAV-S-4 : réarmement — compteur < 7 et dejaMontre == true ->'
        ' SoutienReinitialise émis',
        (tester) async {
          // compteur = 3 (< 7) mais dejaMontre = true -> doit réarmer.
          when(
            () => database.compterSaisiesNegativesConsecutives(),
          ).thenAnswer((_) async => 3);

          final soutienBloc = _MockSoutienBloc();
          whenListen<SoutienState>(
            soutienBloc,
            const Stream<SoutienState>.empty(),
            initialState: const SoutienState(
              dejaMontrePourEpisodeEnCours: true,
            ),
          );

          await tester.pumpWidget(
            _harnessNav(
              states: Stream.value(const DemarragePret()),
              database: database,
              soutienBloc: soutienBloc,
            ),
          );

          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // SoutienReinitialise doit avoir été émis (réarmement).
          verify(
            () => soutienBloc.add(const SoutienReinitialise()),
          ).called(1);
          // Pas de SoutienMontre ni de SoutienPage.
          verifyNever(() => soutienBloc.add(const SoutienMontre()));
          expect(find.byType(SoutienPage), findsNothing);

          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
        },
      );
    },
  );
}
