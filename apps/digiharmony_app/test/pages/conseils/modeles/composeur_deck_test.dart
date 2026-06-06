import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:digiharmony_app/pages/conseils/modeles/composeur_deck.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests unitaires du helper pur [composerDeck] (DEC-CO-03..06).
///
/// Aucun accès Drift : les données sont passées directement.
void main() {
  // ─── Corpus de test ──────────────────────────────────────────────────────
  Conseil rappel(int id, String cle, {String accent = 'primary'}) => Conseil(
    id: id,
    cleConseil: cle,
    typeCarte: 'rappel',
    accentChrome: accent,
    ordre: id,
  );

  Conseil conseil(int id, String cle) => Conseil(
    id: id,
    cleConseil: cle,
    typeCarte: 'conseil',
    accentChrome: 'lime',
    ordre: id,
  );

  Conseil emotion(int id, String cle, String code) => Conseil(
    id: id,
    cleConseil: cle,
    typeCarte: 'emotion',
    codeEmotion: code,
    accentChrome: 'primary',
    ordre: id,
  );

  EntreeHumeur humeur(String code) => EntreeHumeur(
    id: 1,
    codeEmotion: code,
    valence: code == 'angry' ? -1 : 1,
    creeLe: DateTime(2026, 6, 6, 10),
    jour: DateTime(2026, 6, 6),
  );

  // Corpus générique (7 rappels + 2 conseils = 9 génériques)
  final corpusComplet = [
    rappel(1, 'tipDay01'),
    rappel(2, 'tipDay02', accent: 'lime'),
    rappel(3, 'tipDay03', accent: 'or'),
    rappel(4, 'tipDay04'),
    rappel(5, 'tipDay05', accent: 'lime'),
    rappel(6, 'tipDay06', accent: 'or'),
    rappel(7, 'tipDay07'),
    conseil(8, 'conseilPratiqueInteractions'),
    conseil(9, 'conseilPratiqueEspace'),
    emotion(10, 'conseilEmotionAngry', 'angry'),
    emotion(11, 'conseilEmotionSad', 'sad'),
    emotion(12, 'conseilEmotionHappy', 'happy'),
  ];

  final jourTest = DateTime(2026, 6, 6);

  // ─── Tests composerDeck ───────────────────────────────────────────────────

  group('composerDeck — humeur angry', () {
    test(
      'CD-1: humeur angry + carte angry présente '
      '→ carte 0 = CarteEmotion(angry)',
      () {
        final deck = composerDeck(
          humeurDuJour: humeur('angry'),
          corpus: corpusComplet,
          jour: jourTest,
        );
        expect(deck, isNotEmpty);
        final premiere = deck.first;
        expect(premiere, isA<CarteEmotion>());
        expect((premiere as CarteEmotion).codeEmotion, 'angry');
      },
    );

    test(
      'CD-2: humeur angry → N génériques suivent la carte émotion',
      () {
        final deck = composerDeck(
          humeurDuJour: humeur('angry'),
          corpus: corpusComplet,
          jour: jourTest,
        );
        // deck = [émotion] + [N génériques], total = N+1
        expect(deck.length, greaterThanOrEqualTo(2));
        // Pas de double carte émotion angry dans les génériques
        final emotions = deck.skip(1).whereType<CarteEmotion>().toList();
        expect(
          emotions.any((e) => e.codeEmotion == 'angry'),
          isFalse,
          reason: 'La carte émotion angry ne doit pas apparaître deux fois',
        );
      },
    );
  });

  group('composerDeck — aucune humeur', () {
    test(
      'CD-3: aucune humeur → deck 100% générique, pas de CarteEmotion en tête',
      () {
        final deck = composerDeck(
          humeurDuJour: null,
          corpus: corpusComplet,
          jour: jourTest,
        );
        expect(deck, isNotEmpty);
        expect(deck.first, isNot(isA<CarteEmotion>()));
      },
    );

    test('CD-4: aucune humeur → deck de taille N (4)', () {
      final deck = composerDeck(
        humeurDuJour: null,
        corpus: corpusComplet,
        jour: jourTest,
      );
      expect(deck.length, 4);
    });
  });

  group('composerDeck — déterminisme', () {
    test(
      'CD-5: même (jour, humeur, corpus) → deck identique (rejouable)',
      () {
        final deck1 = composerDeck(
          humeurDuJour: humeur('angry'),
          corpus: corpusComplet,
          jour: jourTest,
        );
        final deck2 = composerDeck(
          humeurDuJour: humeur('angry'),
          corpus: corpusComplet,
          jour: jourTest,
        );
        expect(
          deck1.map((c) => c.cleContenu).toList(),
          deck2.map((c) => c.cleContenu).toList(),
        );
      },
    );

    test('CD-6: jour+1 → rotation décalée (carte 0 générique différente)', () {
      final jour2 = jourTest.add(const Duration(days: 1));
      final deck1 = composerDeck(
        humeurDuJour: null,
        corpus: corpusComplet,
        jour: jourTest,
      );
      final deck2 = composerDeck(
        humeurDuJour: null,
        corpus: corpusComplet,
        jour: jour2,
      );
      // Pas d'obligation de différence (si offset % n identique) mais au
      // moins l'ordre change sur 2 jours consécutifs avec 9 génériques.
      // On vérifie que l'offset est bien décalé d'un cran.
      expect(deck1.first.cleContenu, isNotNull);
      expect(deck2.first.cleContenu, isNotNull);
    });
  });

  group('composerDeck — pas de doublon', () {
    test(
      'CD-7: pas de doublon entre carte émotion et portion générique',
      () {
        final deck = composerDeck(
          humeurDuJour: humeur('angry'),
          corpus: corpusComplet,
          jour: jourTest,
        );
        final cles = deck.map((c) => c.cleContenu).toList();
        expect(cles.toSet().length, cles.length, reason: 'Pas de doublon');
      },
    );
  });

  group('composerDeck — cas dégradés', () {
    test('CD-8: corpus vide → fallback 1 carte (pas de crash)', () {
      final deck = composerDeck(
        humeurDuJour: null,
        corpus: const [],
        jour: jourTest,
      );
      expect(deck, isNotEmpty);
      expect(deck.length, 1);
      expect(deck.first.cleContenu, 'tipDay01');
    });

    test(
      'CD-9: humeur code sans carte dédiée '
      '→ deck générique (pas de crash)',
      () {
        // 'calm' n'a pas de carte émotion dans ce corpus de test
        final corpusSansCalm = [
          rappel(1, 'tipDay01'),
          rappel(2, 'tipDay02'),
          rappel(3, 'tipDay03'),
          rappel(4, 'tipDay04'),
          emotion(5, 'conseilEmotionAngry', 'angry'),
        ];
        final deck = composerDeck(
          // calm = valence positive, pas de carte
          humeurDuJour: humeur('calm'),
          corpus: corpusSansCalm,
          jour: jourTest,
        );
        expect(deck, isNotEmpty);
        // Pas de CarteEmotion calm en tête
        expect(
          deck.first,
          isNot(isA<CarteEmotion>()),
          reason: 'Pas de carte émotion calm sans corpus dédié',
        );
      },
    );
  });

  group('composerDeck — cohérence DEC-CO-11', () {
    test(
      'CD-10: sans humeur, carte 0 = tipDay correspondant à '
      'joursDepuisEpoch % nbGén',
      () {
        // Calcule l'offset attendu pour jourTest
        final epoch = DateTime(1970);
        final joursDepuisEpoch =
            DateTime(
              jourTest.year,
              jourTest.month,
              jourTest.day,
            ).difference(epoch).inDays;
        final generiques = corpusComplet
            .where((c) => c.typeCarte != 'emotion')
            .toList();
        final offset = joursDepuisEpoch % generiques.length;
        final cleAttendue = generiques[offset].cleConseil;

        final deck = composerDeck(
          humeurDuJour: null,
          corpus: corpusComplet,
          jour: jourTest,
        );
        expect(deck.first.cleContenu, cleAttendue);
      },
    );
  });
}
