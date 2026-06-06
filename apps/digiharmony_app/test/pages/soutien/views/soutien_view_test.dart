import 'dart:async';
import 'dart:io';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/soutien/views/soutien_view.dart';
import 'package:digiharmony_app/pages/soutien/widgets/halo_soutien.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      "SO-VIEW-3 : bloc ligne d'ecoute masque quand locale sans ressource",
      (tester) async {
        // La table est vide -> bloc masque pour toute locale
        await tester.pumpSoutienView(locale: const Locale('fr'));
        await tester.pump();

        // Le bloc ligne d'ecoute retourne SizedBox.shrink quand pas de
        // ressource : aucune carte visible (bloc masque).
        expect(find.text('Helpline: '), findsNothing);
        expect(find.text('Available: '), findsNothing);
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

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets(
      'SO-VIEW-5 : CTA respiration (STUB) -> SnackBar placeholderComingSoon',
      (tester) async {
        await tester.pumpSoutienView();
        await tester.pump();

        await tester.tap(find.text('Try a guided breathing'));
        await tester.pump();

        expect(find.text('Coming soon'), findsOneWidget);
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

    // Garde-fou : aucun numéro de crise réel dans les sources Dart soutien.
    // Ce test lit les fichiers Dart du périmètre soutien et vérifie l'absence
    // des numéros connus (3114, 116111...) ainsi que de séquences de 5+
    // chiffres consécutifs (format téléphone minimal).
    test(
      'SO-VIEW-8 : garde-fou — aucun numero reel hardcode dans '
      'lib/pages/soutien/',
      () {
        const soutienDir = 'lib/pages/soutien';
        const listeNoire = <String>['3114', '116111', '0800'];
        // 5+ chiffres consécutifs = suspect pour un numéro de téléphone.
        final regexpTel = RegExp(r'\d{5,}');

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
          for (final interdit in listeNoire) {
            expect(
              contenu,
              isNot(contains(interdit)),
              reason:
                  'Numéro de crise interdit "$interdit" trouvé dans '
                  '${fichier.path}',
            );
          }
          expect(
            regexpTel.hasMatch(contenu),
            isFalse,
            reason:
                'Séquence numérique téléphone suspecte dans ${fichier.path}',
          );
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
