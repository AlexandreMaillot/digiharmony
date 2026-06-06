import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/common/placeholder_screen.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_view.dart';
import 'package:digiharmony_app/pages/journal/views/journal_page.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_view.dart';
import 'package:digiharmony_app/pages/temps_ecran/views/temps_ecran_view.dart';
import 'package:digiharmony_app/pages/tuto_notifs/views/tuto_notifs_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccueilBloc extends MockBloc<AccueilEvent, AccueilState>
    implements AccueilBloc {}

class _MockAppDatabase extends Mock implements AppDatabase {}

/// Pompe l'AccueilView avec animations désactivées.
extension PumpNav on WidgetTester {
  Future<void> pumpNavTest(AccueilBloc bloc, {required AppDatabase db}) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
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
    bloc = MockAccueilBloc();
    mockDb = _MockAppDatabase();
    when(
      () => mockDb.conseilDuJour(any()),
    ).thenAnswer((_) async => const Conseil(id: 1, cleConseil: 'tipDay01'));
    when(
      () => mockDb.observerDerniereHumeurDuJour(),
    ).thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
    when(
      () => mockDb.observerEntreesDeLaSemaine(any()),
    ).thenAnswer((_) => const Stream<List<EntreeHumeur>>.empty());
    when(
      () => mockDb.observerEntreesDuMois(any()),
    ).thenAnswer((_) => const Stream<List<EntreeHumeur>>.empty());
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
    // HN-1 : bouton Réglages → PlaceholderScreen.
    testWidgets(
      'HN-1 : Réglages → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
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

    // HN-4 : tuile « Choose your bubble » → PlaceholderScreen.
    testWidgets(
      'HN-4 : Choose your bubble → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.text('Choose your bubble'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-5 : tuile « Tip of the day » → PlaceholderScreen.
    testWidgets(
      'HN-5 : Tip of the day → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.tap(find.text('Tip of the day'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-6 : pilule « Take a break » → PlaceholderScreen.
    testWidgets(
      'HN-6 : Take a break → PlaceholderScreen',
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
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
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

    // HN-8 : lien sœur « Reduce my notifications » → TutoNotifsView.
    testWidgets(
      'HN-8 : Reduce my notifications → TutoNotifsView',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc, db: mockDb);
        await tester.scrollUntilVisible(
          find.text('Reduce my notifications'),
          100,
        );
        await tester.tap(find.text('Reduce my notifications'));
        await tester.pump();
        await tester.pump();
        expect(find.byType(TutoNotifsView), findsOneWidget);
      },
    );
  });
}
