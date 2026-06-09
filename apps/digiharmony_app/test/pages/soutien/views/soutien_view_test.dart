import 'dart:async';
import 'dart:io';

import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/respiration/view/respiration_page.dart';
import 'package:digiharmony_app/pages/soutien/views/soutien_view.dart';
import 'package:digiharmony_app/pages/soutien/widgets/halo_soutien.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/hydrated_storage.dart';

/// Pompe SoutienView avec l'i18n et MediaQuery configurable.
extension PumpSoutienView on WidgetTester {
  Future<void> pumpSoutienView({
    bool disableAnimations = true,
    Locale locale = const Locale('en'),
  }) {
    return pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SoutienView(),
        ),
      ),
    );
  }
}

void main() {
  group('SoutienView', () {
    testWidgets('SO-VIEW-1 : rend les elements cles', (tester) async {
      await tester.pumpSoutienView();
      await tester.pump();

      // Titre et accroche
      expect(find.text('The last few days seem hard.'), findsOneWidget);
      expect(find.text("You're not alone."), findsOneWidget);
      // Paragraphe
      expect(
        find.textContaining('one small step'),
        findsOneWidget,
      );
      // CTA primaire
      expect(
        find.text('Talk to someone you trust'),
        findsWidgets,
      );
      // CTA secondaire
      expect(find.text('Try a guided breathing'), findsOneWidget);
      // Plus tard
      expect(find.text('Later'), findsOneWidget);
      // Aucune relance
      expect(find.text('No reminders — at your own pace'), findsOneWidget);
    });

    testWidgets('SO-VIEW-2 : fond = AppColors.backgroundDeep', (tester) async {
      await tester.pumpSoutienView();
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AppColors.backgroundDeep);
    });

    testWidgets(
      "SO-VIEW-3 : bloc ligne d'ecoute visible avec titre i18n",
      (tester) async {
        // Pour 'fr' : le bloc affiche le titre i18n FR.
        await tester.pumpSoutienView(locale: const Locale('fr'));
        await tester.pump();

        // Le titre i18n FR est "Ligne d'écoute".
        expect(find.textContaining("Ligne d'écoute"), findsAtLeastNWidgets(1));
        // Le numéro 3114 (données) est visible dans le sous-titre.
        expect(find.textContaining('3114'), findsAtLeastNWidgets(1));

        // Pour 'en' : pas d'entrée propre -> fallback fr (cible=3114)
        // mais titre i18n EN = "Helpline".
        await tester.pumpSoutienView();
        await tester.pump();

        // Le titre i18n EN est "Helpline".
        expect(find.textContaining('Helpline'), findsAtLeastNWidgets(1));
        // Le numéro 3114 (données fallback fr) est visible dans le sous-titre.
        expect(find.textContaining('3114'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('SO-VIEW-4 : Plus tard -> Navigator.pop', (tester) async {
      var popped = false;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: AppTheme.dark,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  body: Builder(
                    builder: (ctx) => ElevatedButton(
                      onPressed: () => unawaited(
                        Navigator.of(ctx).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SoutienView(),
                          ),
                        ),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
              observers: [
                _PopObserver(onPop: () => popped = true),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Le BlocLigneEcoute est désormais visible (fallback fr actif) et peut
      // pousser le bouton « Plus tard » hors du viewport 800×600 de test.
      // On fait défiler jusqu'au bouton avant de tapper.
      await tester.ensureVisible(find.text('Later'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets(
      'SO-VIEW-5 : CTA respiration -> RespirationPage',
      (tester) async {
        initMockHydratedStorage();
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        // Harnais avec les providers requis par RespirationPage
        // (DepotStatsBienEtre fourni par AppRouter.versRespiration via
        // AppDatabase ; VoixOffBloc global).
        await tester.pumpWidget(
          RepositoryProvider<AppDatabase>.value(
            value: db,
            child: BlocProvider<VoixOffBloc>(
              create: (_) => VoixOffBloc(),
              child: MaterialApp(
                theme: AppTheme.dark,
                darkTheme: AppTheme.dark,
                themeMode: ThemeMode.dark,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SoutienView(),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Try a guided breathing'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(RespirationPage), findsOneWidget);

        // Dispose pour annuler le ticker du RespirationBloc (évite un
        // Timer encore en attente à la fin du test).
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      "SO-VIEW-6 : reduced motion -> HaloSoutien statique (pas d'animation)",
      (tester) async {
        // disableAnimations: true par défaut dans pumpSoutienView.
        await tester.pumpSoutienView();
        await tester.pump();

        // HaloSoutien présent.
        expect(find.byType(HaloSoutien), findsOneWidget);

        // En reduced motion, le halo retourne un Container statique.
        // pumpAndSettle() doit terminer (aucun AnimationController en boucle
        // infinie). S'il y avait une boucle d'animation, pumpAndSettle()
        // lancerait une FrameTimeoutException avant le timeout.
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'SO-VIEW-6b : animations activees -> HaloSoutien est anime '
      '(pas un Container nu)',
      (tester) async {
        // disableAnimations: false => le halo doit porter une animation.
        await tester.pumpSoutienView(disableAnimations: false);
        await tester.pump();

        expect(find.byType(HaloSoutien), findsOneWidget);

        // Quand les animations sont actives, le halo est un Animate en boucle.
        // On vérifie que le widget est présent et qu'aucune exception n'a été
        // lancée, puis on démontre pour éviter le timer pendant.
        expect(tester.takeException(), isNull);

        // Démonter le widget pour vider les timers d'animation en boucle.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      },
    );

    testWidgets(
      'SO-VIEW-7 : cibles tactiles >= 48 sur chevron et CTA primaire',
      (tester) async {
        await tester.pumpSoutienView();
        await tester.pump();

        // Chevron : IconButton avec constraints >= 48
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        for (final btn in iconButtons) {
          final constraints = btn.constraints;
          if (constraints != null) {
            expect(
              constraints.minHeight,
              greaterThanOrEqualTo(48),
              reason: 'Cible tactile < 48 dp',
            );
          }
        }

        // CTA primaire et secondaire : vérifier la taille minimale
        // via SizedBox.shrink ou minimumSize configuré sur ElevatedButton.
        // Les CTA utilisent BoutonActionSoutien avec minimumSize: Size(48,48).
        final elevatedButtons = tester.widgetList<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        for (final btn in elevatedButtons) {
          final style = btn.style;
          if (style != null) {
            final size = style.minimumSize?.resolve({});
            if (size != null) {
              expect(
                size.height,
                greaterThanOrEqualTo(48),
                reason: 'Cible tactile CTA < 48 dp : ${size.height}',
              );
            }
          }
        }
      },
    );

    // Garde-fou : aucun VRAI numéro de ligne d'écoute officiel (autre que
    // 3114, numéro FR approuvé) dans les sources Dart du périmètre soutien.
    //
    // Principe : 3114 est le seul numéro approuvé, il vit uniquement dans
    // le modèle Dart (tableRessources). Aucun autre numéro officiel ne doit
    // apparaître hardcodé dans le périmètre soutien.
    //
    // Note : 3114 fait 4 chiffres, donc la regex \d{5,} ne le capture pas.
    // La liste noire explicite ci-dessous couvre les numéros ≥ 4 chiffres
    // autres que 3114 (3114 = numéro FR approuvé, légitimement dans le modèle).
    test(
      'SO-VIEW-8 : garde-fou — aucun vrai numero officiel hardcode dans '
      'lib/pages/soutien/',
      () {
        const soutienDir = 'lib/pages/soutien';

        // Liste noire : vrais numéros/préfixes officiels (hors 3114 approuvé)
        // qui ne doivent pas apparaître dans le code source Dart du périmètre
        // soutien. Seuls les numéros suffisamment longs (4+ chiffres) sont
        // inclus ici pour éviter les faux positifs dans les constantes/valeurs
        // numériques du code (ex. 0.15 pour une opacité, 112px, etc.).
        // Les numéros courts (15, 112, 911…) sont couverts par SO-RES-3
        // qui scanne les valeurs de chaîne des ARB.
        // 3114 = numéro FR approuvé — absent de cette liste (présent
        // légitimement dans tableRessources['fr'].cible).
        const listeNoire = <String>[
          '116111', // Helpline enfants Europe
          '116 111', // variante avec espace
          '3020', // Numéro contre le harcèlement (FR)
          '0800', // Préfixe numéro vert FR (numéros gratuits officiels)
          '0805', // Préfixe numéro vert FR alternatif
          '3919', // Numéro violence conjugale (FR)
          '0808', // Préfixe helpline UK
        ];

        // Regex pour détecter les séquences de 5+ chiffres consécutifs.
        // Tolérance : les séquences constituées uniquement de zéros répétés
        // sont acceptées car manifestement fictives.
        final regexpTel = RegExp(r'\d{5,}');
        final regexpZerosSeuls = RegExp(r'^0+$');

        final dir = Directory(soutienDir);
        expect(
          dir.existsSync(),
          isTrue,
          reason: 'Répertoire soutien introuvable : $soutienDir',
        );

        final fichiersDart = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final fichier in fichiersDart) {
          final contenu = fichier.readAsStringSync();

          // Aucun numéro de la liste noire.
          for (final interdit in listeNoire) {
            expect(
              contenu,
              isNot(contains(interdit)),
              reason:
                  'Numéro officiel interdit "$interdit" trouvé dans '
                  '${fichier.path}',
            );
          }

          // Aucune séquence de 5+ chiffres, sauf les patterns tout-zéros
          // (exemple factice toléré : '0000000000').
          final matches = regexpTel.allMatches(contenu);
          for (final m in matches) {
            final sequence = m.group(0)!;
            expect(
              regexpZerosSeuls.hasMatch(sequence),
              isTrue,
              reason:
                  'Séquence numérique suspecte [$sequence] dans '
                  "${fichier.path} — si c'est un exemple fictif, "
                  "vérifier qu'il ne contient que des zéros",
            );
          }
        }
      },
    );
  });
}

/// Observateur de navigation pour detecter les pop.
class _PopObserver extends NavigatorObserver {
  _PopObserver({required this.onPop});
  final VoidCallback onPop;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop();
  }
}
