// Les imports detox/donnees et detox/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'package:digiharmony_app/pages/detox/donnees/depot_audio_detox.dart';
import 'package:digiharmony_app/pages/detox/domaine/usecase/gerer_audio_detox_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDepotAudioDetox extends Mock implements DepotAudioDetox {}

void main() {
  late _MockDepotAudioDetox depot;
  late GererAudioDetoxUseCase useCase;

  setUp(() {
    depot = _MockDepotAudioDetox();
    useCase = GererAudioDetoxUseCase(depot: depot);
    when(
      () => depot.demarrer(any(), mediaTitle: any(named: 'mediaTitle')),
    ).thenAnswer((_) async {});
    when(depot.arreter).thenAnswer((_) async {});
    when(depot.liberer).thenAnswer((_) async {});
  });

  test('demarrer delègue au dépôt avec asset et mediaTitle', () async {
    await useCase.demarrer('assets/audio/detox/mer.mp3', mediaTitle: 'Mer');
    verify(
      () => depot.demarrer(
        'assets/audio/detox/mer.mp3',
        mediaTitle: 'Mer',
      ),
    ).called(1);
  });

  test('arreter delègue au dépôt', () async {
    await useCase.arreter();
    verify(depot.arreter).called(1);
  });

  test('liberer delègue au dépôt', () async {
    await useCase.liberer();
    verify(depot.liberer).called(1);
  });
}
