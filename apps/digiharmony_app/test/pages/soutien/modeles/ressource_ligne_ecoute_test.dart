import 'dart:convert';
import 'dart:io';

import 'package:digiharmony_app/pages/soutien/modeles/ressource_ligne_ecoute.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tableRessources', () {
    // SO-RES-1 : vérifier que les locales autres que 'fr' n'ont pas d'entrée
    // propre (tout doit passer par le fallback 'fr' tant que les partenaires
    // n'ont pas fourni les ressources validées).
    test(
      'SO-RES-1 : locales non couvertes par une entree propre (fallback fr)',
      () {
        expect(tableRessources['en'], isNull);
        expect(tableRessources['el'], isNull);
        expect(tableRessources['it'], isNull);
        expect(tableRessources['ro'], isNull);
        expect(tableRessources['tr'], isNull);
        expect(tableRessources['es'], isNull);
        expect(tableRessources['mk'], isNull);
      },
    );

    // SO-RES-2 : l'entrée 'fr' est présente avec le 3114 (numéro national de
    // prévention du suicide, FR), seul numéro approuvé pour cette locale.
    // Les libellés UI (titre, disponibilité) sont gérés par l'i18n (ARB),
    // pas par le modèle.
    test(
      'SO-RES-2 : entree fr presente avec 3114 approuve et type telephone',
      () {
        final fr = tableRessources['fr'];
        expect(fr, isNotNull, reason: 'Fallback fr requis');
        expect(
          fr!.cible,
          '3114',
          reason: "Cible fr doit être exactement '3114' (numéro FR approuvé)",
        );
        expect(
          fr.type,
          TypeRessourceEcoute.telephone,
          reason: 'Type fr doit être telephone',
        );
      },
    );

    // SO-RES-3 : Garde-fou principal — aucun VRAI numéro de ligne d'écoute
    // officiel ne doit apparaître dans les ARB soutien*.
    //
    // Principe : les ARB ne contiennent jamais de numéros — les données de
    // ressource vivent uniquement dans le modèle Dart (tableRessources).
    // 3114 est le seul numéro approuvé pour 'fr' ; il vit dans le modèle,
    // pas dans les ARB.
    //
    // Ce test échoue si l'un des numéros de la liste noire apparaît dans
    // les valeurs des clés soutien* des ARB fr + en.
    //
    // Pour le modèle Dart : assertion stricte `fr.cible == '3114'` —
    // seul numéro approuvé, tout autre numéro est rejeté.
    test(
      'SO-RES-3 : garde-fou — aucun vrai numero officiel dans ARB soutien*',
      () {
        const arbDir = 'lib/l10n/arb';

        // Liste noire ARB : vrais numéros/préfixes de lignes d'écoute
        // officiels qui ne doivent pas apparaître dans les ARB.
        // 3114 est inclus ici car les ARB ne doivent contenir aucun numéro
        // (3114 vit dans le modèle Dart uniquement).
        const listeNoire = <String>[
          '3114', // Numéro national prévention suicide (FR) — modèle Dart only
          '116111', // Helpline enfants Europe
          '116 111', // variante avec espace
          '119', // Allô enfance en danger (FR)
          '3020', // Numéro contre le harcèlement (FR)
          '0800', // Préfixe numéro vert FR (numéros gratuits officiels)
          '0805', // Préfixe numéro vert FR alternatif
          '3919', // Numéro violence conjugale (FR)
          '15', // SAMU (FR)
          '112', // Urgences européennes
          '911', // Urgences USA
          '988', // Ligne crise suicide USA
          '0808', // Préfixe helpline UK
        ];

        for (final lang in ['fr', 'en']) {
          final fichier = File('$arbDir/app_$lang.arb');
          expect(
            fichier.existsSync(),
            isTrue,
            reason: 'ARB introuvable : $fichier',
          );

          final contenu = fichier.readAsStringSync();
          final arb = jsonDecode(contenu) as Map<String, dynamic>;

          for (final entry in arb.entries) {
            final cle = entry.key;
            final valeur = entry.value;

            if (!cle.startsWith('soutien')) continue;
            if (valeur is! String) continue;

            for (final interdit in listeNoire) {
              expect(
                valeur,
                isNot(contains(interdit)),
                reason:
                    'Numéro officiel interdit "$interdit" trouvé dans la '
                    'clé "$cle" ($lang) : "$valeur"',
              );
            }
          }
        }

        // Vérification stricte du modèle Dart : 3114 est le SEUL numéro
        // approuvé pour 'fr'. Tout autre numéro est rejeté par cette assertion.
        final fr = tableRessources['fr'];
        if (fr != null) {
          expect(
            fr.cible,
            '3114',
            reason:
                "Seul '3114' est approuvé comme cible fr. "
                'Tout autre numéro doit être validé par les partenaires.',
          );
        }
      },
    );
  });

  group('RessourceLigneEcoute', () {
    test('SO-RES-4 : construction avec cible et type (modele reduit)', () {
      const ressource = RessourceLigneEcoute(
        cible: 'TODO_partenaire',
        type: TypeRessourceEcoute.telephone,
      );
      expect(ressource.cible, 'TODO_partenaire');
      expect(ressource.type, TypeRessourceEcoute.telephone);
    });

    test('SO-RES-5 : type lien disponible', () {
      const ressource = RessourceLigneEcoute(
        cible: 'https://example.com',
        type: TypeRessourceEcoute.lien,
      );
      expect(ressource.type, TypeRessourceEcoute.lien);
    });
  });
}
