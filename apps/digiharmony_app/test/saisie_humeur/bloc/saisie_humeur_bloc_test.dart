import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

/// Stub EntreeHumeur pour les tests de pré-sélection.
EntreeHumeur _humeurStub(String code) {
  final now = DateTime.now();
  return EntreeHumeur(
    id: 1,
    codeEmotion: code,
    valence: valencePour(code),
    creeLe: now,
    jour: DateTime(now.year, now.month, now.day),
  );
}

void main() {
  late MockAppDatabase db;

  setUp(() {
    db = MockAppDatabase();
  });

  group('SaisieHumeurBloc — sélection', () {
    // SHB-1 : sélection → EmotionSelectionneeEtat, AUCUNE écriture Drift.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-1 : EmotionSelectionnee → [EmotionSelectionneeEtat] sans UPSERT',
      build: () => SaisieHumeurBloc(database: db),
      act: (bloc) => bloc.add(const EmotionSelectionnee('happy')),
      expect: () => [const EmotionSelectionneeEtat('happy')],
      verify: (_) {
        verifyNever(() => db.enregistrerHumeurDuJour(any()));
      },
    );

    // SHB-2 : re-sélection → la dernière émotion prime.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-2 : re-sélection change la pastille retenue',
      build: () => SaisieHumeurBloc(database: db),
      act: (bloc) => bloc
        ..add(const EmotionSelectionnee('happy'))
        ..add(const EmotionSelectionnee('sad')),
      expect: () => [
        const EmotionSelectionneeEtat('happy'),
        const EmotionSelectionneeEtat('sad'),
      ],
    );
  });

  group('SaisieHumeurBloc — validation', () {
    // SHB-3 : Valider après sélection → EnregistrementEnCours puis Reussi.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-3 : SaisieValidee → [EnCours, Reussi] + UPSERT appelé',
      build: () {
        when(
          () => db.enregistrerHumeurDuJour('happy'),
        ).thenAnswer((_) async => null);
        return SaisieHumeurBloc(database: db);
      },
      seed: () => const EmotionSelectionneeEtat('happy'),
      act: (bloc) => bloc.add(const SaisieValidee()),
      expect: () => [
        const EnregistrementEnCours(codeEmotion: 'happy'),
        const EnregistrementReussi(codeEmotion: 'happy'),
      ],
      verify: (_) {
        verify(() => db.enregistrerHumeurDuJour('happy')).called(1);
      },
    );

    // SHB-4 : Valider sans sélection → no-op (aucune écriture).
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-4 : SaisieValidee sans sélection → aucun état, aucun UPSERT',
      build: () => SaisieHumeurBloc(database: db),
      act: (bloc) => bloc.add(const SaisieValidee()),
      expect: () => const <SaisieHumeurState>[],
      verify: (_) {
        verifyNever(() => db.enregistrerHumeurDuJour(any()));
      },
    );

    // SHB-5 : UPSERT lève → EnregistrementEchoue (sélection conservée).
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-5 : UPSERT exception → [EnCours, Echoue]',
      build: () {
        when(
          () => db.enregistrerHumeurDuJour('nervous'),
        ).thenThrow(Exception('DB error'));
        return SaisieHumeurBloc(database: db);
      },
      seed: () => const EmotionSelectionneeEtat('nervous'),
      act: (bloc) => bloc.add(const SaisieValidee()),
      expect: () => [
        const EnregistrementEnCours(codeEmotion: 'nervous'),
        isA<EnregistrementEchoue>().having(
          (s) => s.codeEmotion,
          'code',
          'nervous',
        ),
      ],
    );

    // SHB-6 : double tap sur Valider pendant l'écriture → un seul UPSERT.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-6 : Valider x2 pendant l’UPSERT ignoré (droppable)',
      build: () {
        when(
          () => db.enregistrerHumeurDuJour(any()),
        ).thenAnswer((_) async => null);
        return SaisieHumeurBloc(database: db);
      },
      seed: () => const EmotionSelectionneeEtat('calm'),
      act: (bloc) => bloc
        ..add(const SaisieValidee())
        ..add(const SaisieValidee()),
      verify: (_) {
        verify(() => db.enregistrerHumeurDuJour('calm')).called(1);
      },
    );
  });

  group('SaisieHumeurBloc — pré-sélection (édition)', () {
    // SHB-7 : ouverture avec humeur du jour existante → pré-sélection.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-7 : SaisieDemarree avec humeur existante → EmotionSelectionneeEtat',
      build: () {
        when(
          () => db.observerDerniereHumeurDuJour(),
        ).thenAnswer((_) => Stream.value(_humeurStub('calm')));
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) => bloc.add(const SaisieDemarree()),
      expect: () => [const EmotionSelectionneeEtat('calm')],
    );

    // SHB-8 : ouverture sans humeur du jour → reste à l'état initial.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-8 : SaisieDemarree sans humeur → aucun état émis',
      build: () {
        when(
          () => db.observerDerniereHumeurDuJour(),
        ).thenAnswer((_) => Stream<EntreeHumeur?>.value(null));
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) => bloc.add(const SaisieDemarree()),
      expect: () => const <SaisieHumeurState>[],
    );
  });
}
