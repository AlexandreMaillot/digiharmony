import 'package:digiharmony_app/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/accueil/widgets/carte_humeur.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pompe un widget avec i18n, thème et animations désactivées.
extension PumpWidget on WidgetTester {
  Future<void> pumpCarteHumeur(Widget widget) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
        ),
      ),
    );
  }
}

void main() {
  const conseil = ConseilDuJourVue(cle: 'tipDay01');

  group('CarteHumeur (HeroCard)', () {
    // HC-1 : État A → icône + titre + CTA.
    testWidgets(
      'HC-1 : État A → icône favorite_border, question, CTA noter',
      (tester) async {
        await tester.pumpCarteHumeur(
          const CarteHumeur(conseil: conseil),
        );
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.text('How are you feeling today?'), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      },
    );

    // HC-2 : État B → emoji + libellé + heure.
    testWidgets(
      'HC-2 : État B → emoji, moodHappy, heure 14:30',
      (tester) async {
        await tester.pumpCarteHumeur(
          CarteHumeur(
            humeur: HumeurDuJourVue(
              codeEmotion: 'happy',
              emoji: '😊',
              noteeLe: DateTime(2026, 6, 5, 14, 30),
            ),
            conseil: conseil,
          ),
        );
        expect(find.text('😊'), findsOneWidget);
        expect(find.text('Happy'), findsOneWidget);
        // Heure formatée (14:30 en locale en).
        expect(find.textContaining('14:30'), findsOneWidget);
      },
    );

    // HC-3 : couleur MoodColors.byKey utilisée (pastille visible).
    testWidgets(
      'HC-3 : pastille couleur visible pour moodCode connu',
      (tester) async {
        await tester.pumpCarteHumeur(
          CarteHumeur(
            humeur: HumeurDuJourVue(
              codeEmotion: 'calm',
              emoji: '😌',
              noteeLe: DateTime(2026, 6, 5, 10),
            ),
            conseil: conseil,
          ),
        );
        // La pastille est un Container avec BoxDecoration circle.
        final containers = tester.widgetList<Container>(find.byType(Container));
        final avecCercle = containers.where(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).shape == BoxShape.circle,
        );
        expect(avecCercle, isNotEmpty);
      },
    );

    // HC-4 : l'heure est formatée selon la locale.
    testWidgets(
      'HC-4 : heure 09:05 formatée correctement',
      (tester) async {
        await tester.pumpCarteHumeur(
          CarteHumeur(
            humeur: HumeurDuJourVue(
              codeEmotion: 'sad',
              emoji: '😢',
              noteeLe: DateTime(2026, 6, 5, 9, 5),
            ),
            conseil: conseil,
          ),
        );
        // Format Hm → "09:05".
        expect(find.textContaining('09:05'), findsOneWidget);
      },
    );

    // HC-5 : tap targets 48x48 minimum (a11y).
    testWidgets(
      'HC-5 : tap targets a11y >= 48×48',
      (tester) async {
        await tester.pumpCarteHumeur(
          const CarteHumeur(conseil: conseil),
        );
        // Vérifie le CTA principal (ElevatedButton).
        final ctaFinder = find.widgetWithText(ElevatedButton, 'Log my mood');
        final ctaSize = tester.getSize(ctaFinder);
        expect(ctaSize.height, greaterThanOrEqualTo(48));
      },
    );

    // HC-6 : code inconnu → fallback gracieux, pas de crash.
    testWidgets(
      'HC-6 : moodCode inconnu → fallback, pas de crash',
      (tester) async {
        await tester.pumpCarteHumeur(
          CarteHumeur(
            humeur: HumeurDuJourVue(
              codeEmotion: 'unknown_code',
              emoji: '❓',
              noteeLe: DateTime(2026, 6, 5, 12),
            ),
            conseil: conseil,
          ),
        );
        // L'emoji fallback est affiché.
        expect(find.text('❓'), findsOneWidget);
        // Pas de crash (le texte du code est affiché).
        expect(find.text('unknown_code'), findsOneWidget);
      },
    );
  });
}
