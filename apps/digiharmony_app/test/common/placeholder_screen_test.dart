import 'package:digiharmony_app/bienvenue/bienvenue_page.dart';
import 'package:digiharmony_app/common/placeholder_screen.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  group('PlaceholderScreen', () {
    testWidgets('PH-1 : affiche le titre et "Coming soon"', (tester) async {
      await tester.pumpWidget(_wrap(const PlaceholderScreen(titre: 'X')));
      await tester.pump();
      expect(find.text('X'), findsWidgets);
      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('PH-2 : BienvenuePage rend un Scaffold sans crash',
        (tester) async {
      await tester.pumpWidget(_wrap(const BienvenuePage()));
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // PH-3 supprimé : AccueilPage n'est plus un placeholder (lit AppDatabase,
    // porte des boucles d'animation). Couvert par test/accueil/.

    testWidgets('PH-4 : fond conforme au thème (scaffoldBackgroundColor)',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlaceholderScreen(titre: 'Y')));
      await tester.pump();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      // Couleur de fond héritée du thème, pas surchargée en dur.
      expect(scaffold.backgroundColor, isNull);
      expect(
        Theme.of(tester.element(find.byType(Scaffold)))
            .scaffoldBackgroundColor,
        AppColors.background,
      );
    });
  });
}
