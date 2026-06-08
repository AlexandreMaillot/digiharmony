// Les imports sens/donnees et sens/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/sens/donnees/depot_audio_sens.dart';
import 'package:digiharmony_app/pages/sens/domaine/usecase/gerer_audio_sens_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDepot extends Mock implements DepotAudioSens {}

void main() {
  setUpAll(() => registerFallbackValue(SensAncrage.see));

  group('GererAudioSensUseCase', () {
    late _MockDepot depot;
    late GererAudioSensUseCase useCase;

    setUp(() {
      depot = _MockDepot();
      useCase = GererAudioSensUseCase(depot: depot);
      when(() => depot.jouerEtape(any())).thenAnswer((_) async {});
      when(depot.arreter).thenAnswer((_) async {});
      when(depot.liberer).thenAnswer((_) async {});
      when(
        () => depot.definirVolume(actif: any(named: 'actif')),
      ).thenAnswer((_) async {});
    });

    test('jouerEtape délègue au dépôt avec le bon sens', () async {
      await useCase.jouerEtape(SensAncrage.touch);

      verify(() => depot.jouerEtape(SensAncrage.touch)).called(1);
    });

    test('arreter délègue au dépôt', () async {
      await useCase.arreter();

      verify(depot.arreter).called(1);
    });

    test('liberer délègue au dépôt', () async {
      await useCase.liberer();

      verify(depot.liberer).called(1);
    });

    test('definirVolume délègue au dépôt avec le bon flag', () async {
      await useCase.definirVolume(actif: true);

      verify(() => depot.definirVolume(actif: true)).called(1);
    });
  });
}
