import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

/// Stub EntreeHumeur pour les tests.
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

  group('SaisieHumeurBloc — EmotionTapee', () {
    // SHB-1 : tap → EnregistrementEnCours puis EnregistrementReussi.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-1 : EmotionTapee → [EnregistrementEnCours, EnregistrementReussi]',
      build: () {
        when(
          () => db.enregistrerHumeurDuJour('happy'),
        ).thenAnswer((_) async => null);
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) => bloc.add(const EmotionTapee('happy')),
      expect: () => [
        const EnregistrementEnCours(codeEmotion: 'happy'),
        const EnregistrementReussi(codeEmotion: 'happy'),
      ],
    );

    // SHB-2 : tap avec ancienne → EnregistrementReussi porte l'ancienne.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-2 : UPSERT retourne ancienne → EnregistrementReussi avec ancienne',
      build: () {
        final ancienne = _humeurStub('calm');
        when(
          () => db.enregistrerHumeurDuJour('sad'),
        ).thenAnswer((_) async => ancienne);
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) => bloc.add(const EmotionTapee('sad')),
      expect: () => [
        const EnregistrementEnCours(codeEmotion: 'sad'),
        isA<EnregistrementReussi>()
            .having((s) => s.codeEmotion, 'code', 'sad')
            .having((s) => s.ancienneEntree?.codeEmotion, 'ancienne', 'calm'),
      ],
    );

    // SHB-3 : UPSERT lève → EnregistrementEchoue.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
        'SHB-3 : UPSERT exception → '
      '[EnregistrementEnCours, EnregistrementEchoue]',
      build: () {
        when(
          () => db.enregistrerHumeurDuJour('nervous'),
        ).thenThrow(Exception('DB error'));
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) => bloc.add(const EmotionTapee('nervous')),
      expect: () => [
        const EnregistrementEnCours(codeEmotion: 'nervous'),
        isA<EnregistrementEchoue>()
            .having((s) => s.codeEmotion, 'code', 'nervous'),
      ],
    );

    // SHB-4 : tap pendant EnregistrementEnCours est droppé (droppable).
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-4 : tap pendant EnregistrementEnCours ignoré (droppable)',
      build: () {
        when(() => db.enregistrerHumeurDuJour(any()))
            .thenAnswer((_) async => null);
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) async {
        // Premier tap puis deuxième immédiat — le second doit être ignoré.
        bloc
          ..add(const EmotionTapee('happy'))
          ..add(const EmotionTapee('sad'));
      },
      // Seul 'happy' passe.
      verify: (bloc) {
        verify(() => db.enregistrerHumeurDuJour('happy')).called(1);
        verifyNever(() => db.enregistrerHumeurDuJour('sad'));
      },
    );
  });

  group('SaisieHumeurBloc — SaisieAnnulee', () {
    // SHB-5 : annulation avec ancienne → restaure → SaisieAnnuleeEtat.
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-5 : annulation avec ancienne → SaisieAnnuleeEtat(code ancienne)',
      build: () {
        final ancienne = _humeurStub('calm');
        when(
          () => db.enregistrerHumeurDuJour('sad'),
        ).thenAnswer((_) async => ancienne);
        when(
          () => db.annulerDerniereSaisie(ancienneEntree: ancienne),
        ).thenAnswer((_) async {});
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) async {
        bloc.add(const EmotionTapee('sad'));
        // Attendre que l'UPSERT soit terminé.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const SaisieAnnulee());
      },
      expect: () => [
        const EnregistrementEnCours(codeEmotion: 'sad'),
        isA<EnregistrementReussi>(),
        const SaisieAnnuleeEtat(codeEmotionRestauree: 'calm'),
      ],
    );

    // SHB-6 : annulation sans ancienne → supprime → SaisieAnnuleeEtat(null).
    blocTest<SaisieHumeurBloc, SaisieHumeurState>(
      'SHB-6 : annulation sans ancienne → SaisieAnnuleeEtat(null)',
      build: () {
        when(
          () => db.enregistrerHumeurDuJour('tired'),
        ).thenAnswer((_) async => null);
        when(
          () => db.annulerDerniereSaisie(),
        ).thenAnswer((_) async {});
        return SaisieHumeurBloc(database: db);
      },
      act: (bloc) async {
        bloc.add(const EmotionTapee('tired'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const SaisieAnnulee());
      },
      expect: () => [
        const EnregistrementEnCours(codeEmotion: 'tired'),
        const EnregistrementReussi(codeEmotion: 'tired'),
        const SaisieAnnuleeEtat(),
      ],
    );
  });
}
