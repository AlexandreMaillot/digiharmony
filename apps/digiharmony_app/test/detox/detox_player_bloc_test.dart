import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/detox/bloc/detox_lecteur_bloc.dart';
import 'package:digiharmony_app/detox/domaine/usecase/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGererAudioDetoxUseCase extends Mock
    implements GererAudioDetoxUseCase {}

class _MockEnregistrerSeanceUseCase extends Mock
    implements EnregistrerSeanceBienEtreUseCase {}

void main() {
  late _MockGererAudioDetoxUseCase audioUseCase;
  late _MockEnregistrerSeanceUseCase enregistrerUseCase;

  setUp(() {
    audioUseCase = _MockGererAudioDetoxUseCase();
    enregistrerUseCase = _MockEnregistrerSeanceUseCase();
    when(
      () => audioUseCase.demarrer(any(), mediaTitle: any(named: 'mediaTitle')),
    ).thenAnswer((_) async {});
    when(audioUseCase.arreter).thenAnswer((_) async {});
    when(audioUseCase.liberer).thenAnswer((_) async {});
    when(
      () => enregistrerUseCase.appeler(any()),
    ).thenAnswer((_) async {});
  });

  DetoxLecteurBloc build({int minutes = 5}) => DetoxLecteurBloc(
    session: SeanceDetox(
      ambianceId: IdAmbianceDetox.sea,
      total: Duration(minutes: minutes),
    ),
    audioUseCase: audioUseCase,
    enregistrerSeanceUseCase: enregistrerUseCase,
    mediaTitle: 'Detox break',
  );

  test('completes when elapsed reaches total and records once', () async {
    final bloc = build(minutes: 1);
    // 60 ticks de 1 s = 1 min.
    for (var i = 0; i < 61; i++) {
      bloc.add(const DetoxLecteurTick());
      await Future<void>.delayed(Duration.zero);
    }
    expect(bloc.state.status, DetoxLecteurStatus.termine);
    verify(() => enregistrerUseCase.appeler('detox')).called(1);
    await bloc.close();
  });

  test('early end stops audio and records nothing', () async {
    final bloc = build()
      ..add(const DetoxLecteurTick())
      ..add(const DetoxLecteurTermine());
    await Future<void>.delayed(Duration.zero);
    verifyNever(() => enregistrerUseCase.appeler(any()));
    verify(audioUseCase.arreter).called(greaterThanOrEqualTo(1));
    await bloc.close();
  });

  test('progress derives from elapsed/total', () async {
    final bloc = build(minutes: 1);
    for (var i = 0; i < 30; i++) {
      bloc.add(const DetoxLecteurTick());
      await Future<void>.delayed(Duration.zero);
    }
    expect(bloc.state.progress, closeTo(0.5, 0.05));
    expect(bloc.state.bloomProgress, bloc.state.progress);
    await bloc.close();
  });
}
