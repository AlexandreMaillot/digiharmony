import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/common/placeholder_screen.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_view.dart';
import 'package:digiharmony_app/pages/bulles/view/bulles_page.dart';
import 'package:digiharmony_app/pages/conseils/views/conseils_page.dart';
import 'package:digiharmony_app/pages/detox/view/detox_config_page.dart';
import 'package:digiharmony_app/pages/journal/views/journal_page.dart';
import 'package:digiharmony_app/pages/parametres/views/parametres_page.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_view.dart';
import 'package:digiharmony_app/pages/temps_ecran/views/temps_ecran_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/hydrated_storage.dart';

class MockAccueilBloc extends MockBloc<AccueilEvent, AccueilState>
    implements AccueilBloc {}

class _MockAppDatabase extends Mock implements AppDatabase {}

/// Pompe l'AccueilView avec animations désactivées.
extension PumpNav on WidgetTester {
  Future<void> pumpNavTest(AccueilBloc bloc, {required AppDatabase db}) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: BlocProvider<LocaleBloc>(
          create: (_) => LocaleBloc(),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RepositoryProvider<AppDatabase>.value(
              value: db,
              child: BlocProvider<AccueilBloc>.value(
                value: bloc,
                child: const AccueilView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  late MockAccueilBloc bloc;
  late _MockAppDatabase mockDb;
  final hapticLog = <MethodCall>[];

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    initMockHydratedStorage();
    bloc = MockAccueilBloc();
    mockDb = _MockAppDatabase();
    when(
      () => mockDb.conseilDuJour(any()),
    ).thenAnswer(
      (_) async => const Conseil(
        id: 1,
        cleConseil: 'tipDay01',
        typeCarte: 'rappel',
        accentChrome: 'primary',
        ordre: 1,
      ),
    );
    when(
      () => mockDb.observerDerniereHumeurDuJour(),
    ).thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
    when(
      () => mockDb.observerEntreesDeLaSemaine(any()),
    ).thenAnswer((_) => const Stream<List<EntreeHumeur>>.empty());
    when(
      () => mockDb.observerEntreesDuMois(any()),
    ).thenAnswer((_) => const Stream<List<EntreeHumeur>>.empty());
    when(
      () => mockDb.lireCorpusConseils(),
    ).thenAnswer(
      (_) async => [
        const Conseil(
          id: 1,
          cleConseil: 'tipDay01',
          typeCarte: 'rappel',
          accentChrome: 'primary',
          ordre: 1,
        ),
      ],
    );
    hapticLog.clear();
    // Intercepte les appels haptiques via le canal de plateforme.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            hapticLog.add(call);
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Vérifie qu'au moins un appel haptique lightImpact a été fait.
  void expectHaptique() {
    expect(
      hapticLog.any(
        (c) =>
            c.method == 'HapticFeedback.vibrate' ||
            c.method == 'SystemSound.play' ||
            c.method.contains('haptic') ||
            c.method.contains('Haptic'),
      ),
      isTrue,
      reason: 'HapticFeedback.lightImpact() attendu mais non déclenché',
    );
    hapticLog.clear();
  }

  group('Navigation placeholders + haptique (AC5)', () {
    // HN-1 : bouton Réglages → ParametresPage (recâblé DEC-PARAM-08).
    testWidgets(
      'HN-1 : Réglages → ParametresPage',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.byIcon(Icons.settings));
        // Utilise pump + durée fixe (la ParametresPage a des FutureBuilder).
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(ParametresPage), findsOneWidget);
      },
    );

    // HN-2 : CTA « Log my mood » (État A) → SaisieHumeurView.
    testWidgets(
      'HN-2 : Log my mood → SaisieHumeurView',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.text('Log my mood'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(SaisieHumeurView), findsOneWidget);
      },
    );

    // HN-3 : « See my journal » → JournalPage (recâblé M2).
    testWidgets(
      'HN-3 : See my journal → JournalPage',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.text('See my journal'));
        // Utilise pump + durée fixe (JournalPage démarre un stream infini).
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(JournalPage), findsOneWidget);
        expect(find.byType(PlaceholderScreen), findsNothing);
      },
    );

    // HN-4 : tuile « Choose your bubble » → BullesPage (hub des exercices).
    testWidgets(
      'HN-4 : Choose your bubble → BullesPage',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.text('Choose your bubble'));
        // BullesPage a des animations en boucle (float/shimmer) : pas de
        // pumpAndSettle ; pump + durée fixe suffit pour la transition.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(BullesPage), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-5 : tuile « Tip of the day » → ConseilsPage (DEC-CO-08).
    testWidgets(
      'HN-5 : Tip of the day → ConseilsPage',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.text('Tip of the day'));
        // ConseilsBloc charge de façon asynchrone : pump + délai.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(ConseilsPage), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-6 : pilule « Take a break » → DetoxConfigPage (config de la pause).
    testWidgets(
      'HN-6 : Take a break → DetoxConfigPage',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        // Scroll pour rendre le widget visible.
        await tester.scrollUntilVisible(
          find.text('Take a break'),
          100,
        );
        await tester.tap(find.text('Take a break'));
        // DetoxConfigPage a des animations en boucle (card-float) : pas de
        // pumpAndSettle ; pump + durée fixe suffit pour la transition.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(DetoxConfigPage), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-7 : lien « My screen time » → TempsEcranView (plus de placeholder).
    testWidgets(
      'HN-7 : My screen time → TempsEcranView',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.scrollUntilVisible(
          find.text('My screen time'),
          100,
        );
        await tester.tap(find.text('My screen time'));
        // Pas de pumpAndSettle (halo respirant) — pump séquentiel.
        await tester.pump();
        await tester.pump();
        expect(find.byType(TempsEcranView), findsOneWidget);
      },
    );

    // HN-8 : le lien « Reduce my notifications » a été retiré de l'Accueil
    // (réalignement maquette Banani). La navigation vers TutoNotifsView se
    // fait désormais depuis l'écran temps d'écran (carte action).
    testWidgets(
      'HN-8 : Reduce my notifications absent de lAccueil',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        expect(find.text('Reduce my notifications'), findsNothing);
      },
    );
  });
}
