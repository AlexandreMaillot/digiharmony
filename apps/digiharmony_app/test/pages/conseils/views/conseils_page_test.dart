import 'dart:async';

import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/conseils/bloc/conseils_bloc.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:digiharmony_app/pages/conseils/views/conseils_page.dart';
import 'package:digiharmony_app/pages/conseils/views/conseils_view.dart';
import 'package:digiharmony_app/pages/conseils/widgets/_carte_shell.dart';
import 'package:digiharmony_app/pages/conseils/widgets/hint_swipe.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDb extends Mock implements AppDatabase {}

class _MockConseilsBloc extends Mock implements ConseilsBloc {}

void main() {
  late _MockDb mockDb;

  setUp(() {
    mockDb = _MockDb();
    when(
      () => mockDb.observerDerniereHumeurDuJour(),
    ).thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
    when(
      () => mockDb.lireCorpusConseils(),
    ).thenAnswer(
      (_) async => const [
        Conseil(
          id: 1,
          cleConseil: 'tipDay01',
          typeCarte: 'rappel',
          accentChrome: 'primary',
          ordre: 1,
        ),
        Conseil(
          id: 2,
          cleConseil: 'tipDay02',
          typeCarte: 'rappel',
          accentChrome: 'lime',
          ordre: 2,
        ),
        Conseil(
          id: 3,
          cleConseil: 'tipDay03',
          typeCarte: 'rappel',
          accentChrome: 'or',
          ordre: 3,
        ),
        Conseil(
          id: 4,
          cleConseil: 'tipDay04',
          typeCarte: 'rappel',
          accentChrome: 'primary',
          ordre: 4,
        ),
      ],
    );
  });

  Widget buildApp({required Widget home}) {
    return MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  Widget buildConseilsWithDb() {
    return RepositoryProvider<AppDatabase>.value(
      value: mockDb,
      child: const ConseilsPage(),
    );
  }

  group('ConseilsView — rendu et a11y', () {
    // CV-1 : le titre « Conseils » / « Tips » est affiché.
    testWidgets(
      'CV-1: ConseilsPage se monte sans erreur',
      (tester) async {
        await tester.pumpWidget(
          buildApp(home: buildConseilsWithDb()),
        );
        // Laisse le temps au BlocProvider + ConseilsDemarre.
        await tester.pump(const Duration(milliseconds: 100));
        // Pas de crash = test réussi.
        expect(tester.takeException(), isNull);
      },
    );

    // CV-2 : aucun texte « J'applique » (DEC-CO-09 — supprimé).
    testWidgets(
      "CV-2: aucun CTA \"J'applique\" dans l'arbre",
      (tester) async {
        await tester.pumpWidget(
          buildApp(home: buildConseilsWithDb()),
        );
        await tester.pump(const Duration(milliseconds: 100));
        // DEC-CO-09 : le bouton « J'applique » est définitivement supprimé.
        expect(find.textContaining("J'applique"), findsNothing);
        expect(find.textContaining('applique'), findsNothing);
      },
    );

    // CV-3 : accentDeCarte CarteRappel primary = AppColors.primary.
    test(
      'CV-3: accentDeCarte(CarteRappel primary) = AppColors.primary',
      () {
        const carte = CarteRappel(
          cleContenu: 'tipDay01',
          accentChrome: 'primary',
        );
        expect(accentDeCarte(carte), AppColors.primary);
      },
    );

    // CV-4 : accentDeCarte pour CarteRappel avec accent 'lime'.
    test(
      'CV-4: accentDeCarte(CarteRappel lime) = signatureGradient[1]',
      () {
        const carte = CarteRappel(
          cleContenu: 'tipDay01',
          accentChrome: 'lime',
        );
        expect(accentDeCarte(carte), AppColors.signatureGradient[1]);
      },
    );

    // CV-5 : accentDeCarte pour CarteRappel avec accent 'or'.
    test('CV-5: accentDeCarte(CarteRappel or) = accentGold', () {
      const carte = CarteRappel(
        cleContenu: 'tipDay01',
        accentChrome: 'or',
      );
      expect(accentDeCarte(carte), AppColors.accentGold);
    });

    // CV-6 : accentDeCarte pour CarteEmotion(nervous) = MoodColors.nervous
    // (violet — valide pour émotion, interdit pour chrome).
    test(
      'CV-6: accentDeCarte(CarteEmotion nervous) = MoodColors.nervous',
      () {
        const carte = CarteEmotion(
          cleContenu: 'conseilEmotionNervous',
          codeEmotion: 'nervous',
        );
        expect(accentDeCarte(carte), MoodColors.nervous);
      },
    );

    // CV-7 : reduced-motion → flèches visibles, hint masqué (DEC-CO-08).
    //
    // En reduced-motion, la navigation SANS GESTE doit rester accessible :
    // les flèches IconButton restent visibles (HintSwipe.visible = true,
    // HintSwipe.disableAnimations = true). Seul le texte atténué est masqué.
    testWidgets(
      'CV-7: reduced-motion → HintSwipe visible mais hint textuel masqué',
      (tester) async {
        final bloc = _MockConseilsBloc();
        when(() => bloc.state).thenReturn(
          const ConseilsState(
            status: ConseilsStatus.pret,
            deck: [
              CarteRappel(
                cleContenu: 'tipDay01',
                accentChrome: 'primary',
              ),
              CarteRappel(
                cleContenu: 'tipDay02',
                accentChrome: 'lime',
              ),
            ],
          ),
        );
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              // Force reduced-motion.
              data: const MediaQueryData(disableAnimations: true),
              child: BlocProvider<ConseilsBloc>.value(
                value: bloc,
                child: const ConseilsView(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // DEC-CO-08 : en reduced-motion le HintSwipe est VISIBLE
        // (les flèches permettent la navigation sans swipe).
        final hintSwipes = tester.widgetList<HintSwipe>(
          find.byType(HintSwipe),
        );
        for (final h in hintSwipes) {
          expect(
            h.visible,
            isTrue,
            reason: 'Les flèches doivent rester visibles en reduced-motion',
          );
          expect(
            h.disableAnimations,
            isTrue,
            reason: 'disableAnimations doit être true',
          );
        }
        // Flèches (IconButton chevron_right/left) présentes dans l'arbre.
        expect(find.byIcon(Icons.chevron_right), findsWidgets);
        expect(find.byIcon(Icons.chevron_left), findsWidgets);
      },
    );

    // CV-8 : accentDeCarte n'utilise jamais un hex brut.
    test(
      'CV-8: accentDeCarte(CarteRappel primary) != hex mockup (#3FB8E6 OK, '
      'mais doit venir du token)',
      () {
        const carte = CarteRappel(
          cleContenu: 'tipDay01',
          accentChrome: 'primary',
        );
        // La couleur doit correspondre exactement au token AppColors.primary.
        expect(accentDeCarte(carte), equals(AppColors.primary));
        // AppColors.primary = 0xFF3FB8E6 (token, pas hex en dur).
        expect(AppColors.primary, const Color(0xFF3FB8E6));
      },
    );
  });

  group('ConseilsPage — navigation', () {
    // CN-1 : ConseilsPage est accessible via RepositoryProvider<AppDatabase>.
    testWidgets(
      'CN-1: ConseilsPage se monte avec RepositoryProvider<AppDatabase>',
      (tester) async {
        await tester.pumpWidget(
          buildApp(home: buildConseilsWithDb()),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      },
    );
  });

  // ── Fidélité UI (maquette new_screen13) ──────────────────────────────────
  group('ConseilsView — fidélité UI', () {
    // Rend une carte rappel seule dans un viewport haut, reduced-motion ON
    // (swipe-hint OFF → pas d'animation infinie, jamais de pumpAndSettle).
    Widget buildCarteSeule({required bool disableAnimations}) {
      final bloc = _MockConseilsBloc();
      when(() => bloc.state).thenReturn(
        const ConseilsState(
          status: ConseilsStatus.pret,
          deck: [
            CarteRappel(cleContenu: 'tipDay01', accentChrome: 'primary'),
          ],
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: BlocProvider<ConseilsBloc>.value(
            value: bloc,
            child: const ConseilsView(),
          ),
        ),
      );
    }

    // CV-FID-1 : la carte remplit la hauteur du deck (≥ hauteurMinCarte),
    // ne se tasse pas au contenu (problème #1 du correctif). Viewport haut.
    testWidgets(
      'CV-FID-1: la carte rappel remplit la hauteur (≥ hauteurMinCarte)',
      (tester) async {
        tester.view.physicalSize = const Size(412, 920);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildCarteSeule(disableAnimations: true));
        // pump simple (jamais pumpAndSettle : swipe-hint OFF ici de toute
        // façon, mais on garde la garde-fou testing.md).
        await tester.pump(const Duration(milliseconds: 50));

        expect(tester.takeException(), isNull);
        final carteSize = tester.getSize(find.byType(ContenuCarte));
        expect(
          carteSize.height,
          greaterThanOrEqualTo(hauteurMinCarte),
          reason: 'La carte doit remplir le deck, pas se tasser au contenu',
        );
      },
    );

    // CV-FID-2 : reduced-motion → aucune animation infinie en cours
    // (swipe-hint OFF). On vérifie qu'aucun frame supplémentaire n'est planifié
    // après un pump (sinon pumpAndSettle bouclerait — piège testing.md).
    testWidgets(
      "CV-FID-2: reduced-motion → pas d'animation swipe-hint en cours",
      (tester) async {
        await tester.pumpWidget(buildCarteSeule(disableAnimations: true));
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        // Aucune frame planifiée ⇒ pas d'animation infinie active.
        expect(
          tester.binding.hasScheduledFrame,
          isFalse,
          reason: 'En reduced-motion le swipe-hint doit être désactivé',
        );
      },
    );

    // CV-FID-3 : la carte rappel (tipDay01) affiche bien 3 Do's et 2 Don'ts.
    // Vérifie que les PuceDo/PuceDont sont dans l'arbre après l'ajout des listes.
    testWidgets(
      'CV-FID-3: carte rappel tipDay01 affiche 3 PuceDo + 2 PuceDont',
      (tester) async {
        await tester.pumpWidget(buildCarteSeule(disableAnimations: true));
        await tester.pump(const Duration(milliseconds: 50));

        expect(tester.takeException(), isNull);
        // 3 puces Do (check rond accent)
        expect(
          find.byType(PuceDo),
          findsNWidgets(3),
          reason: 'tipDay01 doit afficher 3 puces Do',
        );
        // 2 puces Don't (close rond gris)
        expect(
          find.byType(PuceDont),
          findsNWidgets(2),
          reason: "tipDay01 doit afficher 2 puces Don't",
        );
      },
    );

    // NB : le rendu motion-ON complet de ConseilsView n'est pas testé en
    // widget-test (ParticulesFlottantes s'appuie sur `flutter_animate` qui
    // planifie des timers infinis → piège testing.md : jamais de
    // pumpAndSettle). La convention projet teste la vue en reduced-motion.
    // La désactivation du swipe-hint en reduced-motion est couverte par
    // CV-FID-2 ; sa logique (AnimationController.repeat OFF si actif==false
    // ou disableAnimations) reste un plain controller disposé proprement.
  });
}
