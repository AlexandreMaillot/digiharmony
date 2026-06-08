// Les imports etirement/donnees et etirement/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/etirement/bloc/etirement_bloc.dart';
import 'package:digiharmony_app/pages/etirement/donnees/depot_audio_etirement.dart';
import 'package:digiharmony_app/pages/etirement/domaine/usecase/usecase.dart';
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
    when(depotAudio.mettreEnPause).thenAnswer((_) async {});
    when(depotAudio.reprendre).thenAnswer((_) async {});
    when(depotAudio.arreter).thenAnswer((_) async {});
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

  group('mute de volume (voix off)', () {
    test('jouerSegment est appelé même quand la voix off est inactive',
        () async {
      // voiceover est initialisé active: false.
      final bloc = build()..add(const EtirementDemarre());
      await Future<void>.delayed(Duration.zero);

      verify(
        () => depotAudio.jouerSegment(any()),
      ).called(greaterThanOrEqualTo(1));
      await bloc.close();
    });

    test(
        'definirVolume est appliqué au démarrage avec le flag initial (false)',
        () async {
      final bloc = build();
      await Future<void>.delayed(Duration.zero);

      verify(
        () => depotAudio.definirVolume(actif: false),
      ).called(greaterThanOrEqualTo(1));
      await bloc.close();
    });

    test('basculer la voix off appelle definirVolume sur le dépôt audio',
        () async {
      final bloc = build();
      await Future<void>.delayed(Duration.zero);
      clearInteractions(depotAudio);

      voiceover.add(const VoixOffBasculee());
      await Future<void>.delayed(Duration.zero);

      verify(
        () => depotAudio.definirVolume(actif: any(named: 'actif')),
      ).called(1);
      await bloc.close();
    });
  });
}
