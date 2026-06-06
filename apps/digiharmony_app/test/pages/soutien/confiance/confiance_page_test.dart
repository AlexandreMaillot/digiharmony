import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/soutien/confiance/confiance_page.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpConfiance on WidgetTester {
  Future<void> pumpConfiancePage({
    Locale locale = const Locale('en'),
  }) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ConfiancePage(),
        ),
      ),
    );
  }
}

void main() {
  group('ConfiancePage', () {
    testWidgets('SO-CONF-1 : affiche le titre, le paragraphe et les pistes', (
      tester,
    ) async {
      await tester.pumpConfiancePage();
      await tester.pump();

      expect(
        find.text('Talk to someone you trust'),
        findsAtLeastNWidgets(1),
      );
      // Le texte 'trusted adult' peut apparaître dans le paragraphe ET
      // dans la piste 03 — on vérifie juste la présence.
      expect(
        find.textContaining('trusted adult'),
        findsAtLeastNWidgets(1),
      );

      // Les 5 pistes bienveillantes doivent toutes être présentes.
      expect(find.textContaining('close friend'), findsOneWidget);
      expect(find.textContaining('family member'), findsOneWidget);
      expect(find.textContaining('trusted adult at school'), findsOneWidget);
      expect(find.textContaining('Write down'), findsOneWidget);
      expect(find.textContaining('calm moment'), findsOneWidget);
    });

    testWidgets('SO-CONF-2 : fond = AppColors.backgroundDeep', (tester) async {
      await tester.pumpConfiancePage();
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AppColors.backgroundDeep);
    });

    testWidgets('SO-CONF-3 : chevron -> Navigator.pop', (tester) async {
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
                            builder: (_) => const ConfiancePage(),
                          ),
                        ),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
              observers: [_PopObserver(onPop: () => popped = true)],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('SO-CONF-4 : aucun formulaire ni champ de saisie', (
      tester,
    ) async {
      await tester.pumpConfiancePage();
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('SO-CONF-5 : cible tactile chevron >= 48dp', (tester) async {
      await tester.pumpConfiancePage();
      await tester.pump();

      final iconButtons = tester.widgetList<IconButton>(
        find.byType(IconButton),
      );
      for (final btn in iconButtons) {
        final constraints = btn.constraints;
        if (constraints != null) {
          expect(constraints.minHeight, greaterThanOrEqualTo(48));
        }
      }
    });
  });
}

class _PopObserver extends NavigatorObserver {
  _PopObserver({required this.onPop});
  final VoidCallback onPop;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop();
  }
}
