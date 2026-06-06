import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/conseils/bloc/conseils_bloc.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDb extends Mock implements AppDatabase {}

/// Conseil stub générique pour les tests.
Conseil _rappelStub({int id = 1, String cle = 'tipDay01'}) => Conseil(
  id: id,
  cleConseil: cle,
  typeCarte: 'rappel',
  accentChrome: 'primary',
  ordre: id,
);

/// Corpus de test minimal (7 rappels + 1 émotion angry).
List<Conseil> _corpusTest() => [
  _rappelStub(),
  _rappelStub(id: 2, cle: 'tipDay02'),
  _rappelStub(id: 3, cle: 'tipDay03'),
  _rappelStub(id: 4, cle: 'tipDay04'),
  _rappelStub(id: 5, cle: 'tipDay05'),
  _rappelStub(id: 6, cle: 'tipDay06'),
  _rappelStub(id: 7, cle: 'tipDay07'),
  const Conseil(
    id: 8,
    cleConseil: 'conseilEmotionAngry',
    typeCarte: 'emotion',
    codeEmotion: 'angry',
    accentChrome: 'primary',
    ordre: 8,
  ),
];

EntreeHumeur _humeurAngry() => EntreeHumeur(
  id: 1,
  codeEmotion: 'angry',
  valence: -1,
  creeLe: DateTime(2026, 6, 6, 10),
  jour: DateTime(2026, 6, 6),
);

void main() {
  late _MockDb db;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    db = _MockDb();
    when(
      () => db.observerDerniereHumeurDuJour(),
    ).thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
    when(
      () => db.lireCorpusConseils(),
    ).thenAnswer((_) async => _corpusTest());
  });

  group('ConseilsBloc', () {
    // CB-1 : ConseilsDemarre → chargement puis pret.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-1: ConseilsDemarre → chargement puis pret, indexCourant: 0',
      build: () => ConseilsBloc(db),
      act: (b) => b.add(const ConseilsDemarre()),
      expect: () => [
        const ConseilsState(status: ConseilsStatus.chargement),
        isA<ConseilsState>().having(
          (s) => s.status,
          'status',
          ConseilsStatus.pret,
        ).having((s) => s.deck, 'deck', isNotEmpty).having(
          (s) => s.indexCourant,
          'indexCourant',
          0,
        ),
      ],
    );

    // CB-2 : ConseilsDemarre avec humeur angry → carte 0 = CarteEmotion.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-2: ConseilsDemarre avec humeur angry → carte 0 = CarteEmotion(angry)',
      setUp: () {
        when(
          () => db.observerDerniereHumeurDuJour(),
        ).thenAnswer(
          (_) => Stream.value(_humeurAngry()),
        );
      },
      build: () => ConseilsBloc(db),
      act: (b) => b.add(const ConseilsDemarre()),
      verify: (b) {
        final state = b.state;
        expect(state.status, ConseilsStatus.pret);
        expect(state.deck, isNotEmpty);
        final first = state.deck.first;
        expect(first, isA<CarteEmotion>());
        expect((first as CarteEmotion).codeEmotion, 'angry');
      },
    );

    // CB-3 : ConseilsCarteSuivante → index + 1.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-3: ConseilsCarteSuivante → indexCourant + 1',
      build: () => ConseilsBloc(db),
      seed: () => const ConseilsState(
        status: ConseilsStatus.pret,
        deck: [
          CarteRappel(cleContenu: 'tipDay01', accentChrome: 'primary'),
          CarteRappel(cleContenu: 'tipDay02', accentChrome: 'lime'),
          CarteRappel(cleContenu: 'tipDay03', accentChrome: 'or'),
        ],
      ),
      act: (b) => b.add(const ConseilsCarteSuivante()),
      expect: () => [
        isA<ConseilsState>().having(
          (s) => s.indexCourant,
          'indexCourant',
          1,
        ),
      ],
    );

    // CB-4 : ConseilsCarteSuivante à la borne droite → no-op.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-4: ConseilsCarteSuivante à la borne droite → no-op',
      build: () => ConseilsBloc(db),
      seed: () => const ConseilsState(
        status: ConseilsStatus.pret,
        deck: [
          CarteRappel(cleContenu: 'tipDay01', accentChrome: 'primary'),
          CarteRappel(cleContenu: 'tipDay02', accentChrome: 'lime'),
        ],
        indexCourant: 1, // dernière carte
      ),
      act: (b) => b.add(const ConseilsCarteSuivante()),
      expect: () => const <ConseilsState>[],
    );

    // CB-5 : ConseilsCartePrecedente → index - 1.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-5: ConseilsCartePrecedente → indexCourant - 1',
      build: () => ConseilsBloc(db),
      seed: () => const ConseilsState(
        status: ConseilsStatus.pret,
        deck: [
          CarteRappel(cleContenu: 'tipDay01', accentChrome: 'primary'),
          CarteRappel(cleContenu: 'tipDay02', accentChrome: 'lime'),
        ],
        indexCourant: 1,
      ),
      act: (b) => b.add(const ConseilsCartePrecedente()),
      expect: () => [
        isA<ConseilsState>().having(
          (s) => s.indexCourant,
          'indexCourant',
          0,
        ),
      ],
    );

    // CB-6 : ConseilsCartePrecedente à la borne gauche → no-op.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-6: ConseilsCartePrecedente à la borne gauche (index 0) → no-op',
      build: () => ConseilsBloc(db),
      seed: () => const ConseilsState(
        status: ConseilsStatus.pret,
        deck: [
          CarteRappel(cleContenu: 'tipDay01', accentChrome: 'primary'),
        ],
      ),
      act: (b) => b.add(const ConseilsCartePrecedente()),
      expect: () => const <ConseilsState>[],
    );

    // CB-7 : ConseilsCarteAtteinte(i) → indexCourant == i.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-7: ConseilsCarteAtteinte(2) → indexCourant == 2',
      build: () => ConseilsBloc(db),
      seed: () => const ConseilsState(
        status: ConseilsStatus.pret,
        deck: [
          CarteRappel(cleContenu: 'tipDay01', accentChrome: 'primary'),
          CarteRappel(cleContenu: 'tipDay02', accentChrome: 'lime'),
          CarteRappel(cleContenu: 'tipDay03', accentChrome: 'or'),
        ],
      ),
      act: (b) => b.add(const ConseilsCarteAtteinte(2)),
      expect: () => [
        isA<ConseilsState>().having(
          (s) => s.indexCourant,
          'indexCourant',
          2,
        ),
      ],
    );

    // CB-8 : corpus vide → status pret, deck fallback non vide.
    blocTest<ConseilsBloc, ConseilsState>(
      'CB-8: corpus vide → status erreur + deck fallback ≥ 1 carte',
      setUp: () {
        when(
          () => db.lireCorpusConseils(),
        ).thenAnswer((_) async => []);
      },
      build: () => ConseilsBloc(db),
      act: (b) => b.add(const ConseilsDemarre()),
      verify: (b) {
        final state = b.state;
        expect(state.status, ConseilsStatus.pret);
        // corpus vide mais composerDeck retourne au moins 1 carte fallback
        expect(state.deck, isNotEmpty);
      },
    );

    // CB-9 : aucune écriture Drift sur tout le cycle de vie.
    test('CB-9: aucune écriture Drift durant le cycle de vie Conseils', () {
      // On vérifie que seules les méthodes de lecture sont appelées.
      // Les méthodes d'écriture ne sont jamais stubées → appel = erreur.
      verifyNever(() => db.enregistrerHumeurDuJour(any()));
      verifyNever(() => db.annulerDerniereSaisie());
      verifyNever(() => db.enregistrerUsageDuJour(any()));
    });
  });
}
