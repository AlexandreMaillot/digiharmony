// Les imports etirement/donnees et etirement/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/etirement/bloc/etirement_bloc.dart';
import 'package:digiharmony_app/etirement/donnees/depot_audio_etirement.dart';
import 'package:digiharmony_app/etirement/domaine/usecase/usecase.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockDepotAudioEtirement extends Mock implements DepotAudioEtirement {}

void main() {
  late FakeDepotStatsBienEtre repository;
  late _MockDepotAudioEtirement depotAudio;
  late VoixOffBloc voiceover;

  setUpAll(() => registerFallbackValue(IdSegmentEtirement.anchor));

  setUp(() {
    final storage = MockHydratedStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
    HydratedBloc.storage = storage;

    repository = FakeDepotStatsBienEtre();
    depotAudio = _MockDepotAudioEtirement();
    when(() => depotAudio.jouerSegment(any())).thenAnswer((_) async {});
    when(depotAudio.arreter).thenAnswer((_) async {});
    when(depotAudio.mettreEnPause).thenAnswer((_) async {});
    when(depotAudio.reprendre).thenAnswer((_) async {});
    when(depotAudio.liberer).thenAnswer((_) async {});
    when(
      () => depotAudio.definirVolume(actif: any(named: 'actif')),
    ).thenAnswer((_) async {});
    voiceover = VoixOffBloc()..add(const VoixOffDefinie(active: false));
  });

  tearDown(() async {
    await voiceover.close();
  });

  EtirementBloc build() => EtirementBloc(
    routine: RoutineEtirement.routineParDefaut,
    enregistrerSeance: EnregistrerSeanceBienEtreUseCase(depot: repository),
    gererAudio: GererAudioEtirementUseCase(depot: depotAudio),
    lireVoixOff: LirePreferenceVoixOffUseCase(voixOffBloc: voiceover),
  );

  // 200ms tick, total 60s = 300 ticks. We feed ticks manually (no real timer).
  Future<void> feedTicks(EtirementBloc bloc, int count) async {
    for (var i = 0; i < count; i++) {
      bloc.add(const EtirementTick());
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('advances segments and completes, records once', () async {
    final bloc = build();
    // Force initial state without arming a real timer.
    await feedTicks(bloc, 320); // > 300 ticks (60s / 200ms)
    expect(bloc.state.status, EtirementStatus.termine);
    expect(repository.recorded.where((e) => e == 'stretch').length, 1);
    await bloc.close();
  });

  test('global elapsed advances with ticks; segment index increases',
      () async {
    final bloc = build();
    // First segment is 10s = 50 ticks; after ~60 ticks we should be on seg 1.
    await feedTicks(bloc, 60);
    expect(bloc.state.segmentIndex, greaterThanOrEqualTo(1));
    expect(bloc.state.globalElapsed.inSeconds, greaterThanOrEqualTo(10));
    await bloc.close();
  });

  test('pause stops the ticker and keeps elapsed; restart resets', () async {
    final bloc = build();
    await feedTicks(bloc, 10);
    bloc.add(const EtirementPauseBasculee());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.status, EtirementStatus.enPause);

    bloc.add(const EtirementRedemarree());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.segmentIndex, 0);
    expect(bloc.state.segmentElapsed, Duration.zero);
    expect(bloc.state.statsPersisted, isFalse);
    await bloc.close();
  });
}
