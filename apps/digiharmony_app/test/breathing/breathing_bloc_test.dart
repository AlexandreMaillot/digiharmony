import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/respiration/bloc/respiration_bloc.dart';
import 'package:digiharmony_app/pages/respiration/domaine/usecase/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockGererAudio extends Mock implements GererAudioRespirationUseCase {}

class _MockLireVoixOff extends Mock implements LirePreferenceVoixOffUseCase {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeDepotStatsBienEtre repository;
  late _MockGererAudio gererAudio;
  late _MockLireVoixOff lireVoixOff;

  setUpAll(() {
    registerFallbackValue(PhaseRespiration.inhale);
  });

  setUp(() {
    final storage = MockHydratedStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
    HydratedBloc.storage = storage;

    repository = FakeDepotStatsBienEtre();

    gererAudio = _MockGererAudio();
    when(() => gererAudio.jouerPhase(any())).thenAnswer((_) async {});
    when(gererAudio.arreter).thenAnswer((_) async {});
    when(gererAudio.liberer).thenAnswer((_) async {});
    when(gererAudio.mettreEnPause).thenAnswer((_) async {});
    when(gererAudio.reprendre).thenAnswer((_) async {});
    when(
      () => gererAudio.definirVolume(actif: any(named: 'actif')),
    ).thenAnswer((_) async {});

    lireVoixOff = _MockLireVoixOff();
    when(lireVoixOff.appeler).thenReturn(false);
    when(lireVoixOff.flux).thenAnswer((_) => const Stream<bool>.empty());
  });

  RespirationBloc build() => RespirationBloc(
    session: SeanceRespiration.quatreDeuxSix,
    enregistrerSeance: EnregistrerSeanceBienEtreUseCase(depot: repository),
    gererAudio: gererAudio,
    lireVoixOff: lireVoixOff,
  );

  // Avance manuellement la machine en injectant des ticks (3 phases/cycle).
  Future<void> runToCompletion(RespirationBloc bloc) async {
    const ticksTotal = 3 * 5; // 3 phases x 5 cycles
    for (var i = 0; i < ticksTotal; i++) {
      bloc.add(const RespirationTick());
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('completes after 5 cycles and records the session exactly once',
      () async {
    final bloc = build()..add(const RespirationDemarree());
    await Future<void>.delayed(Duration.zero);

    await runToCompletion(bloc);

    expect(bloc.state.status, RespirationStatus.terminee);
    expect(repository.recorded.where((e) => e == 'breathing').length, 1);
    await bloc.close();
  });

  test('quitting before the end does not record', () async {
    final bloc = build()..add(const RespirationDemarree());
    await Future<void>.delayed(Duration.zero);

    bloc
      ..add(const RespirationTick())
      ..add(const RespirationMiseEnPause());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.status, RespirationStatus.enPause);
    expect(repository.recorded, isEmpty);
    await bloc.close();
  });

  test('restart resets to cycle 0 / inhale and clears statsPersisted',
      () async {
    final bloc = build()..add(const RespirationDemarree());
    await Future<void>.delayed(Duration.zero);
    await runToCompletion(bloc);
    expect(bloc.state.status, RespirationStatus.terminee);

    bloc.add(const RespirationRedemarree());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.status, RespirationStatus.enCours);
    expect(bloc.state.cycleIndex, 0);
    expect(bloc.state.phase, PhaseRespiration.inhale);
    expect(bloc.state.statsPersisted, isFalse);
    await bloc.close();
  });
}
