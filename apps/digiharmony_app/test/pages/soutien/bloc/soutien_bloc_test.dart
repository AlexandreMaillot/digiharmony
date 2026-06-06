import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/pages/soutien/bloc/soutien_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/hydrated_storage.dart';

void main() {
  group('SoutienBloc', () {
    late MockStorage storage;

    setUp(() {
      storage = initMockHydratedStorage();
    });

    test('SO-BLOC-1 : état initial = false', () {
      expect(
        SoutienBloc().state.dejaMontrePourEpisodeEnCours,
        isFalse,
      );
    });

    blocTest<SoutienBloc, SoutienState>(
      'SO-BLOC-2 : SoutienMontre émet dejaMontre = true',
      build: SoutienBloc.new,
      act: (bloc) => bloc.add(const SoutienMontre()),
      expect: () => [const SoutienState(dejaMontrePourEpisodeEnCours: true)],
    );

    blocTest<SoutienBloc, SoutienState>(
      'SO-BLOC-3 : SoutienReinitialise émet dejaMontre = false',
      build: SoutienBloc.new,
      seed: () => const SoutienState(dejaMontrePourEpisodeEnCours: true),
      act: (bloc) => bloc.add(const SoutienReinitialise()),
      expect: () => [const SoutienState(dejaMontrePourEpisodeEnCours: false)],
    );

    test('SO-BLOC-4 : round-trip toJson/fromJson (shown = true)', () {
      final bloc = SoutienBloc();
      final json = bloc.toJson(
        const SoutienState(dejaMontrePourEpisodeEnCours: true),
      );
      expect(bloc.fromJson(json).dejaMontrePourEpisodeEnCours, isTrue);
    });

    test('SO-BLOC-5 : round-trip toJson/fromJson (shown = false)', () {
      final bloc = SoutienBloc();
      final json = bloc.toJson(const SoutienState());
      expect(bloc.fromJson(json).dejaMontrePourEpisodeEnCours, isFalse);
    });

    test('SO-BLOC-6 : hydratation depuis storage {shown: true}', () {
      when(() => storage.read('SoutienBlocsoutien')).thenReturn(
        <String, dynamic>{'shown': true},
      );
      expect(
        SoutienBloc().state.dejaMontrePourEpisodeEnCours,
        isTrue,
      );
    });

    test('SO-BLOC-7 : la clé de stockage est "soutien"', () {
      expect(SoutienBloc().id, 'soutien');
    });

    test('SO-BLOC-8 : SoutienState.copyWith fonctionne', () {
      const etat = SoutienState();
      final copie = etat.copyWith(dejaMontrePourEpisodeEnCours: true);
      expect(copie.dejaMontrePourEpisodeEnCours, isTrue);
    });

    test('SO-BLOC-9 : Equatable — égalité structurelle', () {
      expect(
        const SoutienState(dejaMontrePourEpisodeEnCours: true),
        const SoutienState(dejaMontrePourEpisodeEnCours: true),
      );
    });

    blocTest<SoutienBloc, SoutienState>(
      'SO-BLOC-10 : scénario épisode complet — '
      'montré → re-éval ne re-montre pas → réinitialisé → remonte',
      build: SoutienBloc.new,
      act: (bloc) async {
        // 1. Montré (premier épisode)
        bloc.add(const SoutienMontre());
        await Future<void>.delayed(Duration.zero);
        // 2. Re-éval à 7 : SoutienMontre encore
        //    (état déjà true → pas de double affichage car bloc_test
        //    émet uniquement les changements distincts)
        bloc.add(const SoutienMontre());
        await Future<void>.delayed(Duration.zero);
        // 3. Compteur retombe < 7 → réinitialise
        bloc.add(const SoutienReinitialise());
        await Future<void>.delayed(Duration.zero);
        // 4. Nouveau déclenchement → remonte
        bloc.add(const SoutienMontre());
      },
      expect: () => [
        const SoutienState(dejaMontrePourEpisodeEnCours: true),
        const SoutienState(dejaMontrePourEpisodeEnCours: false),
        const SoutienState(dejaMontrePourEpisodeEnCours: true),
      ],
    );
  });
}
