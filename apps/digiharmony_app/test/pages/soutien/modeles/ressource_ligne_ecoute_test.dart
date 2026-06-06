import 'dart:convert';
import 'dart:io';

import 'package:digiharmony_app/pages/soutien/modeles/ressource_ligne_ecoute.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tableRessources', () {
    test('SO-RES-1 : locale non couverte -> null (bloc masque)', () {
      expect(tableRessources['fr'], isNull);
      expect(tableRessources['en'], isNull);
      expect(tableRessources['el'], isNull);
    });

    test('SO-RES-2 : table vide par defaut (aucun numero reel hardcode)', () {
      expect(tableRessources, isEmpty);
    });

    // Garde-fou : aucun numéro de crise réel dans les ARBs soutien*.
    // Ce test lit les fichiers source fr + en et vérifie que les valeurs
    // des clés « soutien* » ne contiennent aucune séquence de 3+ chiffres
    // consécutifs (pattern d'un numéro de ligne d'écoute) ni aucune valeur
    // de la liste noire connue.
    test(
      'SO-RES-3 : garde-fou — aucun numero reel dans les ARB soutien*',
      () {
        const arbDir = 'lib/l10n/arb';
        const listeNoire = <String>['3114', '116111', '0800'];
        // Regex : 3 chiffres consécutifs ou plus
        final regexpChiffres = RegExp(r'\d{3,}');

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

            // Ne tester que les clés soutien* (valeurs string uniquement).
            if (!cle.startsWith('soutien')) continue;
            if (valeur is! String) continue;

            // Aucun numéro de liste noire.
            for (final interdit in listeNoire) {
              expect(
                valeur,
                isNot(contains(interdit)),
                reason:
                    'Numéro de crise interdit "$interdit" trouvé dans la '
                    'clé "$cle" ($lang) : "$valeur"',
              );
            }

            // Aucune séquence de 3+ chiffres consécutifs.
            expect(
              regexpChiffres.hasMatch(valeur),
              isFalse,
              reason:
                  'Séquence numérique suspecte dans la clé "$cle" ($lang) '
                  ': "$valeur"',
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
