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

    // Garde-fou : aucun numero reel (ex. 3114) dans le code source.
    // Ce test verifie que la table est bien vide.
    test('SO-RES-3 : garde-fou — aucun numero de crise hardcode', () {
      for (final ressource in tableRessources.values) {
        expect(
          ressource.cible,
          isNot(contains('3114')),
          reason: 'Aucun numero de ligne de crise reel ne doit etre hardcode',
        );
      }
    });
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
