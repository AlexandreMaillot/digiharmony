import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock de la base Drift pour les tests du bloc.
class MockAppDatabase extends Mock implements AppDatabase {}

/// Conseil stub pour les tests.
Conseil _conseilStub({String cle = 'tipDay03'}) =>
    Conseil(id: 1, cleConseil: cle);

/// Entrée d'humeur stub pour les tests.
EntreeHumeur _humeurStub({
  String code = 'happy',
  DateTime? loggedAt,
}) => EntreeHumeur(
  id: 1,
  codeEmotion: code,
  valence: 1,
  creeLe: loggedAt ?? DateTime(2026, 6, 5, 14, 30),
);

/// Configure le mock DB pour émettre [valeurs] depuis le stream d'humeur.
///
/// Utilise un [Stream.fromIterable] qui se ferme après toutes les émissions,
/// ce qui permet à `emit.forEach` de se terminer proprement.
void _mockStream(
  MockAppDatabase db,
  List<EntreeHumeur?> valeurs, {
  String conseilCle = 'tipDay03',
}) {
  when(
    () => db.conseilDuJour(any()),
  ).thenAnswer((_) async => _conseilStub(cle: conseilCle));
  when(
    () => db.observerDerniereHumeurDuJour(),
  ).thenAnswer((_) => Stream.fromIterable(valeurs));
}

void main() {
  late MockAppDatabase db;

  setUp(() {
    db = MockAppDatabase();
    registerFallbackValue(DateTime.now());
  });

  group('AccueilBloc', () {
    // HB-1 : état initial = AccueilChargement.
    test('HB-1 : état initial est AccueilChargement', () async {
      _mockStream(db, []);
      final bloc = AccueilBloc(database: db);
      expect(bloc.state, isA<AccueilChargement>());
      await bloc.close();
    });

    // HB-2 : stream émet null → AccueilPret(humeurDuJour: null) = État A.
    blocTest<AccueilBloc, AccueilState>(
      'HB-2 : null → État A (humeurDuJour == null)',
      setUp: () => _mockStream(db, [null]),
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      expect: () => [
        isA<AccueilPret>().having(
          (s) => s.humeurDuJour,
          'humeurDuJour',
          isNull,
        ),
      ],
    );

    // HB-3 : stream émet une entrée → AccueilPret(humeurDuJour: non-null) = B.
    blocTest<AccueilBloc, AccueilState>(
      'HB-3 : entrée du jour → État B (humeurDuJour != null)',
      setUp: () => _mockStream(db, [_humeurStub()]),
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      expect: () => [
        isA<AccueilPret>().having(
          (s) => s.humeurDuJour,
          'humeurDuJour',
          isNotNull,
        ),
      ],
    );

    // HB-4 : bascule réactive null → entrée.
    blocTest<AccueilBloc, AccueilState>(
      'HB-4 : bascule A→B réactive (null puis entrée)',
      setUp: () => _mockStream(db, [null, _humeurStub()]),
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      expect: () => [
        isA<AccueilPret>().having((s) => s.humeurDuJour, 'état-A', isNull),
        isA<AccueilPret>().having((s) => s.humeurDuJour, 'état-B', isNotNull),
      ],
    );

    // HB-5 : mapping correct du HumeurDuJourVue.
    blocTest<AccueilBloc, AccueilState>(
      'HB-5 : HumeurDuJourVue porte codeEmotion, emoji, noteeLe',
      setUp: () => _mockStream(
        db,
        [_humeurStub(code: 'calm', loggedAt: DateTime(2026, 6, 5, 14, 30))],
      ),
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      expect: () => [
        isA<AccueilPret>().having(
          (s) => s.humeurDuJour,
          'humeurDuJour',
          isA<HumeurDuJourVue>()
              .having((h) => h.codeEmotion, 'codeEmotion', 'calm')
              .having((h) => h.emoji, 'emoji', '😌')
              .having(
                (h) => h.noteeLe,
                'noteeLe',
                DateTime(2026, 6, 5, 14, 30),
              ),
        ),
      ],
    );

    // HB-6 : conseil du jour reflété dans AccueilPret.
    blocTest<AccueilBloc, AccueilState>(
      'HB-6 : conseil du jour = tipDay03',
      setUp: () => _mockStream(db, [null]),
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      expect: () => [
        isA<AccueilPret>().having(
          (s) => s.conseil.cle,
          'conseil.cle',
          'tipDay03',
        ),
      ],
    );

    // HB-7 : erreur Drift (Exception) → AccueilErreur.
    blocTest<AccueilBloc, AccueilState>(
      'HB-7 : exception Drift → AccueilErreur',
      setUp: () {
        when(() => db.conseilDuJour(any())).thenThrow(Exception('Drift error'));
        when(
          () => db.observerDerniereHumeurDuJour(),
        ).thenAnswer((_) => Stream.fromIterable([null]));
      },
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      expect: () => [isA<AccueilErreur>()],
    );

    // HB-10 : StateError (base vide) → AccueilErreur — fallback État A (AC7).
    // `conseilDuJour` lève StateError si la base est vide (app_database.dart).
    // Le `on Object` du bloc doit le capturer ; l'écran affiche l'État A.
    blocTest<AccueilBloc, AccueilState>(
      'HB-10 : StateError base vide → AccueilErreur (fallback État A)',
      setUp: () {
        when(
          () => db.conseilDuJour(any()),
        ).thenThrow(StateError('Aucun conseil seedé dans la base.'));
        when(
          () => db.observerDerniereHumeurDuJour(),
        ).thenAnswer((_) => Stream.fromIterable([null]));
      },
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      expect: () => [isA<AccueilErreur>()],
    );

    // HB-8 : AccueilDemarre restartable.
    // Le 2e AccueilDemarre annule l'abonnement du 1er et en crée un nouveau.
    // La DB est appelée 2x pour conseilDuJour et observerDerniereHumeurDuJour.
    blocTest<AccueilBloc, AccueilState>(
      'HB-8 : AccueilDemarre restartable',
      setUp: () {
        when(
          () => db.conseilDuJour(any()),
        ).thenAnswer((_) async => _conseilStub());
        // Le stream est recréé à chaque appel — comportement normal de Drift.
        when(
          () => db.observerDerniereHumeurDuJour(),
        ).thenAnswer((_) => Stream.fromIterable([null]));
      },
      build: () => AccueilBloc(database: db),
      act: (bloc) async {
        bloc.add(const AccueilDemarre());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const AccueilDemarre());
      },
      verify: (bloc) {
        // observerDerniereHumeurDuJour appelé 2 fois = 2 démarrages.
        verify(() => db.observerDerniereHumeurDuJour()).called(greaterThan(1));
      },
    );

    // HB-9 : lecture seule — seules les méthodes de lecture sont appelées.
    blocTest<AccueilBloc, AccueilState>(
      'HB-9 : seules les méthodes de lecture sont appelées',
      setUp: () => _mockStream(db, [null]),
      build: () => AccueilBloc(database: db),
      act: (bloc) => bloc.add(const AccueilDemarre()),
      verify: (bloc) {
        verify(() => db.observerDerniereHumeurDuJour()).called(1);
        verify(() => db.conseilDuJour(any())).called(1);
        verifyNoMoreInteractions(db);
      },
    );
  });
}
