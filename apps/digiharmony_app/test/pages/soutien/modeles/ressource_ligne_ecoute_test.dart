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

    // SO-RES-2 : l'entrée 'fr' est présente (exemple factice pour la preview)
    // et son numéro est manifestement fictif (0000000000 uniquement).
    test(
      'SO-RES-2 : entree fr presente et manifestement factice',
      () {
        final fr = tableRessources['fr'];
        expect(fr, isNotNull, reason: 'Fallback fr requis pour la preview');
        expect(
          fr!.cible,
          '0000000000',
          reason:
              'Cible fr doit rester le numéro exemple factice '
              '(0000000000) — pas un vrai numéro de crise',
        );
        expect(
          fr.nom,
          contains('exemple'),
          reason:
              'Le libellé doit contenir "exemple" pour éviter toute '
              'confusion lors de la recette',
        );
      },
    );

    // SO-RES-3 : Garde-fou principal — aucun VRAI numéro de ligne d'écoute
    // officiel ne doit apparaître dans les ARB soutien* ni dans le code source
    // de cette table.
    //
    // Principe : un écran destiné à des mineurs ne doit jamais présenter un
    // numéro de crise officiel (3114, 116 111, 119, etc.) hardcodé comme
    // donnée certifiée — ces numéros doivent être fournis et validés par les
    // partenaires du projet Erasmus+.
    //
    // Ce test échoue si l'un des numéros de la liste noire apparaît dans :
    //   - les valeurs des clés soutien* des ARB fr + en
    //   - la valeur `cible` de l'entrée 'fr' de tableRessources
    //
    // L'exemple factice '0000000000' est explicitement toléré : il ne
    // correspond à aucun service réel et son libellé "exemple — à valider"
    // le rend impossible à confondre avec une ressource officielle.
    test(
      'SO-RES-3 : garde-fou — aucun vrai numero officiel dans ARB soutien*',
      () {
        const arbDir = 'lib/l10n/arb';

        // Liste noire : vrais numéros/préfixes de lignes d'écoute officiels.
        // Ajouter tout nouveau numéro connu ici.
        const listeNoire = <String>[
          '3114', // Numéro national prévention suicide (FR)
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

        // Tolérances explicites : patterns manifestement fictifs.
        // '0000000000' est toléré car c'est l'exemple factice déclaré.
        bool estTolereDansArb(String valeur) {
          // Une valeur qui ne contient que des zéros répétés est fictive.
          final sansBlancs = valeur.replaceAll(' ', '');
          final regexpZeros = RegExp(r'^0+$');
          return regexpZeros.hasMatch(sansBlancs);
        }

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
            if (estTolereDansArb(valeur)) continue;

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

        // Vérification directe : la cible de l'entrée fr ne doit pas
        // contenir un vrai numéro de la liste noire.
        final fr = tableRessources['fr'];
        if (fr != null) {
          for (final interdit in listeNoire) {
            expect(
              fr.cible,
              isNot(contains(interdit)),
              reason:
                  'Cible fr contient un numéro officiel interdit : '
                  '"$interdit" dans "${fr.cible}"',
            );
          }
        }
      },
    );
  });

  group('RessourceLigneEcoute', () {
    test('SO-RES-4 : construction avec tous les champs', () {
      const ressource = RessourceLigneEcoute(
        nom: 'Test Helpline',
        cible: 'TODO_partenaire',
        type: TypeRessourceEcoute.telephone,
        disponibilite: '24h/24',
      );
      expect(ressource.nom, 'Test Helpline');
      expect(ressource.cible, 'TODO_partenaire');
      expect(ressource.type, TypeRessourceEcoute.telephone);
      expect(ressource.disponibilite, '24h/24');
    });

    test('SO-RES-5 : type lien disponible', () {
      const ressource = RessourceLigneEcoute(
        nom: 'Test Web',
        cible: 'https://example.com',
        type: TypeRessourceEcoute.lien,
        disponibilite: 'Lundi-Vendredi',
      );
      expect(ressource.type, TypeRessourceEcoute.lien);
    });
  });
}
