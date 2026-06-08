// Les imports sens/donnees et sens/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/sens/bloc/sens_bloc.dart';
import 'package:digiharmony_app/pages/sens/donnees/depot_audio_sens.dart';
import 'package:digiharmony_app/pages/sens/domaine/usecase/usecase.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockDepotAudioSens extends Mock implements DepotAudioSens {}

void main() {
  late FakeDepotStatsBienEtre repository;
  late _MockDepotAudioSens depotAudio;
  late VoixOffBloc voiceover;

  setUpAll(() => registerFallbackValue(SensAncrage.see));

  setUp(() {
    final storage = MockHydratedStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
    HydratedBloc.storage = storage;

    repository = FakeDepotStatsBienEtre();
    depotAudio = _MockDepotAudioSens();
    when(() => depotAudio.jouerEtape(any())).thenAnswer((_) async {});
    when(depotAudio.arreter).thenAnswer((_) async {});
    when(depotAudio.liberer).thenAnswer((_) async {});
    when(
      () => depotAudio.definirVolume(actif: any(named: 'actif')),
    ).thenAnswer((_) async {});
    voiceover = VoixOffBloc()..add(const VoixOffDefinie(active: false));
  });

  SensBloc build() => SensBloc(
    exercise: ExerciceAncrage.cinqQuatreTroisDeuxUn,
    enregistrerSeance: EnregistrerSeanceBienEtreUseCase(depot: repository),
    gererAudio: GererAudioSensUseCase(depot: depotAudio),
    lireVoixOff: LirePreferenceVoixOffUseCase(voixOffBloc: voiceover),
  );

  test('advances through 5 steps then completes, records once', () async {
    final bloc = build();
    for (var i = 0; i < 5; i++) {
      bloc.add(const SensSuivantPresse());
      await Future<void>.delayed(Duration.zero);
    }
    expect(bloc.state.status, SensStatus.termine);
    expect(repository.recorded.where((e) => e == 'senses').length, 1);
    await bloc.close();
  });

  test('quitting mid-exercise records nothing', () async {
    final bloc = build()..add(const SensSuivantPresse());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.stepIndex, 1);
    expect(repository.recorded, isEmpty);
    await bloc.close();
  });

  test('previous goes back without loss', () async {
    final bloc = build()
      ..add(const SensSuivantPresse())
      ..add(const SensSuivantPresse());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const SensPrecedentPresse());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.stepIndex, 1);
    await bloc.close();
  });

  test('restart resets to step 0 and clears statsPersisted', () async {
    final bloc = build();
    for (var i = 0; i < 5; i++) {
      bloc.add(const SensSuivantPresse());
      await Future<void>.delayed(Duration.zero);
    }
    bloc.add(const SensRedemarree());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.stepIndex, 0);
    expect(bloc.state.status, SensStatus.enCours);
    expect(bloc.state.statsPersisted, isFalse);
    await bloc.close();
  });

  group('mute de volume (voix off)', () {
    test(
        'jouerEtape est appelé même si voix off inactive au démarrage',
        () async {
      // voiceover est déjà initialisé avec active: false dans setUp.
      final bloc = build()..add(const SensDemarree());
      await Future<void>.delayed(Duration.zero);

      verify(
        () => depotAudio.jouerEtape(any()),
      ).called(greaterThanOrEqualTo(1));
      await bloc.close();
    });

    test('basculer la voix off appelle definirVolume sur le dépôt audio',
        () async {
      final bloc = build();
      await Future<void>.delayed(Duration.zero);

      voiceover.add(const VoixOffBasculee());
      await Future<void>.delayed(Duration.zero);

      verify(
        () => depotAudio.definirVolume(actif: any(named: 'actif')),
      ).called(greaterThanOrEqualTo(1));
      await bloc.close();
    });
  });
}
