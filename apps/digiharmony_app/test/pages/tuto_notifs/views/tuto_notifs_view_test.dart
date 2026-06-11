import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/tuto_notifs/views/tuto_notifs_view.dart';
import 'package:digiharmony_app/pages/tuto_notifs/widgets/carte_encouragement.dart';
import 'package:digiharmony_app/pages/tuto_notifs/widgets/carte_etape.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension on WidgetTester {
  Future<void> pumpTuto({CibleOs os = CibleOs.android}) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TutoNotifsView(osForce: os),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('TN-1 : Android → 5 étapes + intro + encouragement', (
    tester,
  ) async {
    await tester.pumpTuto();
    await tester.pump();

    expect(find.text('Reduce my notifications'), findsOneWidget);
    expect(find.text('Fewer notifications, more calm.'), findsOneWidget);
    expect(find.byType(CarteEtape), findsNWidgets(5));
    expect(find.byType(CarteEncouragement), findsOneWidget);
    // Étape spécifique Android.
    expect(find.text('Do Not Disturb mode'), findsOneWidget);
  });

  testWidgets('TN-2 : iOS → étapes iOS distinctes', (tester) async {
    await tester.pumpTuto(os: CibleOs.ios);
    await tester.pump();
    expect(find.byType(CarteEtape), findsNWidgets(5));
    expect(find.text('Repeat for each app'), findsOneWidget);
    // L'étape Android spécifique ne doit pas apparaître.
    expect(find.text('Do Not Disturb mode'), findsNothing);
  });

  testWidgets("AC7 : footer rassurance (l'app n'émet pas de notifs)", (
    tester,
  ) async {
    await tester.pumpTuto();
    await tester.pump();
    expect(
      find.textContaining('never sends you notifications'),
      findsOneWidget,
    );
  });

  // Écran poussé sur la bottom bar : bouton Fermer (X) au lieu du chevron
  // retour (DEC-NAV-2026). Cible tactile ≥ 48×48.
  testWidgets('AC11 : bouton Fermer ≥ 48×48', (tester) async {
    await tester.pumpTuto();
    await tester.pump();
    final taille = tester.getSize(find.byTooltip('Close'));
    expect(taille.width, greaterThanOrEqualTo(48));
    expect(taille.height, greaterThanOrEqualTo(48));
  });
}
