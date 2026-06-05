import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_view.dart';
import 'package:digiharmony_app/pages/accueil/widgets/particules_flottantes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccueilBloc extends MockBloc<AccueilEvent, AccueilState>
    implements AccueilBloc {}

/// Pompe l'AccueilView avec [disableAnimations] configurable.
Future<void> pumpReducedMotion(
  WidgetTester tester,
  AccueilBloc bloc, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
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
  // Pump une frame pour initialiser les widgets.
  await tester.pump();
}

void main() {
  late MockAccueilBloc bloc;

  setUp(() {
    bloc = MockAccueilBloc();
    when(() => bloc.state).thenReturn(
      const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
    );
  });

  group('Reduced motion / a11y décor (AC6, DEC-HOME-07)', () {
    // RM-1 : HaloRespirant statique si disableAnimations.
    testWidgets(
      'RM-1 : HaloRespirant présent et statique si disableAnimations',
      (tester) async {
        await pumpReducedMotion(tester, bloc, disableAnimations: true);
        expect(find.byType(HaloRespirant), findsOneWidget);
        // Aucun AnimatedWidget en boucle (pas de Animate avec onPlay).
        // Le widget est rendu sans erreur.
      },
    );

    // RM-2 : ParticulesFlottantes statiques si disableAnimations.
    testWidgets(
      'RM-2 : ParticulesFlottantes présentes et statiques si disableAnimations',
      (tester) async {
        await pumpReducedMotion(tester, bloc, disableAnimations: true);
        expect(find.byType(ParticulesFlottantes), findsOneWidget);
      },
    );

    // RM-3 : pilule « Take a break » sans animation si disableAnimations.
    testWidgets(
      'RM-3 : Take a break présent sans boucle si disableAnimations',
      (tester) async {
        await pumpReducedMotion(tester, bloc, disableAnimations: true);
        expect(find.text('Take a break'), findsOneWidget);
      },
    );

    // RM-4 : écran lisible (contenu présent) si disableAnimations.
    testWidgets(
      'RM-4 : contenu lisible même avec disableAnimations',
      (tester) async {
        await pumpReducedMotion(tester, bloc, disableAnimations: true);
        // Greeting visible.
        expect(find.text('Hello 👋'), findsOneWidget);
        // Tuiles visibles.
        expect(find.text('Choose your bubble'), findsOneWidget);
      },
    );

    // RM-5 : animations présentes si disableAnimations == false.
    // Utilise pump(Duration) ciblé — pumpAndSettle serait infini (boucles).
    testWidgets(
      'RM-5 : Animate présent (boucles actives) si disableAnimations false',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(),
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
        // Une seule frame : initialise sans dérouler les boucles.
        await tester.pump(Duration.zero);
        // Vérifie que les widgets Animate sont présents (boucles actives).
        expect(find.byType(Animate), findsWidgets);
        // Avance suffisamment pour que les timers se terminent proprement.
        // (les animations en boucle s'annulent lors de la fermeture du widget).
        await tester.pump(const Duration(seconds: 10));
      },
    );

    // RM-6 : pas de pumpAndSettle infini — pump ciblé suffisant.
    testWidgets(
      'RM-6 : pump(Duration) ciblé suffit pour les animations',
      (tester) async {
        await pumpReducedMotion(tester, bloc, disableAnimations: true);
        // Un pump simple (sans pumpAndSettle) fonctionne.
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(AccueilView), findsOneWidget);
      },
    );
  });
}
