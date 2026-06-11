import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccueilBloc extends MockBloc<AccueilEvent, AccueilState>
    implements AccueilBloc {}

/// Pompe l'AccueilView avec animations désactivées (évite timersPending).
extension PumpAccueil on WidgetTester {
  Future<void> pumpAccueil(AccueilBloc bloc) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AccueilBloc>.value(
            value: bloc,
            child: const AccueilView(),
          ),
        ),
      ),
    );
  }
}

void main() {
  late MockAccueilBloc bloc;

  setUp(() {
    bloc = MockAccueilBloc();
  });

  group('AccueilView', () {
    // HV-1 : AccueilChargement → skeleton neutre (pas de spinner agressif).
    testWidgets(
      'HV-1 : AccueilChargement → skeleton visible, écran rendu',
      (tester) async {
        when(() => bloc.state).thenReturn(const AccueilChargement());
        await tester.pumpAccueil(bloc);
        // Skeleton = Container coloré (pas de spinner).
        expect(find.byType(CircularProgressIndicator), findsNothing);
        // L'écran principal est rendu.
        expect(find.byType(AccueilView), findsOneWidget);
      },
    );

    // HV-2 : AccueilPret(null) → État A : heroMoodQuestion + heroLogMoodCta.
    testWidgets(
      'HV-2 : État A (humeur null) → question + CTA noter',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(
            conseil: ConseilDuJourVue(cle: 'tipDay01'),
          ),
        );
        await tester.pumpAccueil(bloc);
        // heroMoodQuestion présent.
        expect(find.text('How are you feeling today?'), findsWidgets);
        // heroLogMoodCta présent.
        expect(find.text('Log my mood'), findsOneWidget);
        // heroSeeJournal présent.
        expect(find.text('See my journal'), findsOneWidget);
      },
    );

    // HV-3 : AccueilPret(non-null) → État B : emoji + prefix + heure.
    testWidgets(
      'HV-3 : État B (humeur non-null) → emoji + prefix + journal',
      (tester) async {
        when(() => bloc.state).thenReturn(
          AccueilPret(
            humeurDuJour: HumeurDuJourVue(
              codeEmotion: 'happy',
              emoji: '😊',
              noteeLe: DateTime(2026, 6, 5, 14, 30),
            ),
            conseil: const ConseilDuJourVue(cle: 'tipDay01'),
          ),
        );
        await tester.pumpAccueil(bloc);
        // Emoji visible.
        expect(find.text('😊'), findsOneWidget);
        // heroMoodTodayPrefix présent.
        expect(find.text('Today you are feeling'), findsOneWidget);
        // heroSeeJournal présent.
        expect(find.text('See my journal'), findsOneWidget);
        // CTA « Log my mood » absent en état B.
        expect(find.text('Log my mood'), findsNothing);
      },
    );

    // HV-4 : AccueilErreur → fallback État A, pas de crash.
    testWidgets(
      'HV-4 : AccueilErreur → fallback État A, pas de crash',
      (tester) async {
        when(() => bloc.state).thenReturn(const AccueilErreur());
        await tester.pumpAccueil(bloc);
        // L'écran est rendu sans crash.
        expect(find.byType(AccueilView), findsOneWidget);
        // Le CTA État A est présent (fallback).
        expect(find.text('Log my mood'), findsOneWidget);
      },
    );

    // HV-5 : wordmark « DigiHarmony » non traduit présent (AC8).
    testWidgets(
      'HV-5 : wordmark DigiHarmony présent (uppercase, non traduit)',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpAccueil(bloc);
        // Le wordmark est en uppercase via .toUpperCase().
        expect(find.text('DIGIHARMONY'), findsOneWidget);
      },
    );

    // HV-6 : greeting fixe (DEC-HOME-04).
    testWidgets(
      'HV-6 : greeting homeGreeting + homeGreetingSubtitle présents',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpAccueil(bloc);
        // Le greeting scinde le texte et l'emoji 👋 (agrandi/animé).
        expect(find.text('Hello'), findsOneWidget);
        expect(find.text('👋'), findsOneWidget);
        expect(find.text('How are you feeling today?'), findsWidgets);
      },
    );

    // HV-7 : grille 2 tuiles présentes.
    testWidgets(
      'HV-7 : homeToolBubble + homeToolDailyTip présents',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpAccueil(bloc);
        expect(find.text('Choose your bubble'), findsOneWidget);
        expect(find.text('Tip of the day'), findsOneWidget);
      },
    );

    // HV-8 : pilule + lien temps d'écran présents.
    testWidgets(
      'HV-8 : homePauseCta + homeScreenTime présents',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpAccueil(bloc);
        expect(find.text('Take a break'), findsOneWidget);
        expect(find.text('My screen time'), findsOneWidget);
      },
    );
  });
}
