import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/parametres/modeles/langue_supportee.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('languesSupportees', () {
    test(
      'PM-MOD-1 : AC9 — codes alignés sur supportedLocales',
      () {
        final codesSupportees =
            languesSupportees.map((l) => l.code).toSet();
        final codesApp = AppLocalizations.supportedLocales
            .map((l) => l.languageCode)
            .toSet();

        expect(
          codesSupportees,
          equals(codesApp),
          reason:
              'languesSupportees doit rester '
              'synchronisée avec supportedLocales',
        );
      },
    );

    test(
      "PM-MOD-2 : 8 langues exactement dans l'ordre de la maquette",
      () {
        const ordreAttendu = [
          'en',
          'fr',
          'el',
          'it',
          'ro',
          'tr',
          'es',
          'mk',
        ];
        final codesDansLaListe =
            languesSupportees.map((l) => l.code).toList();
        expect(codesDansLaListe, ordreAttendu);
      },
    );

    test(
      'PM-MOD-3 : tous les endonymes et drapeaux sont non vides',
      () {
        for (final langue in languesSupportees) {
          expect(langue.endonyme, isNotEmpty);
          expect(langue.drapeau, isNotEmpty);
          expect(langue.code, isNotEmpty);
        }
      },
    );
  });
}
