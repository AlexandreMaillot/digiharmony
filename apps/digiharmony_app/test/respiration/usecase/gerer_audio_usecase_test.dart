// Les imports respiration/donnees et respiration/domaine déclenchent un faux
// positif directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/respiration/donnees/donnees.dart';
import 'package:digiharmony_app/respiration/domaine/usecase/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDepot extends Mock implements DepotAudioRespiration {}

void main() {
  setUpAll(() => registerFallbackValue(PhaseRespiration.inhale));

  group('GererAudioRespirationUseCase', () {
    late _MockDepot depot;
    late GererAudioRespirationUseCase useCase;

    setUp(() {
      depot = _MockDepot();
      useCase = GererAudioRespirationUseCase(depot: depot);
      when(() => depot.jouerPhase(any())).thenAnswer((_) async {});
      when(depot.mettreEnPause).thenAnswer((_) async {});
      when(depot.reprendre).thenAnswer((_) async {});
      when(depot.arreter).thenAnswer((_) async {});
      when(depot.liberer).thenAnswer((_) async {});
      when(
        () => depot.definirVolume(actif: any(named: 'actif')),
      ).thenAnswer((_) async {});
    });

    test('jouerPhase délègue au dépôt avec la bonne phase', () async {
      await useCase.jouerPhase(PhaseRespiration.exhale);

      verify(() => depot.jouerPhase(PhaseRespiration.exhale)).called(1);
    });

    test('mettreEnPause délègue au dépôt', () async {
      await useCase.mettreEnPause();

      verify(depot.mettreEnPause).called(1);
    });

    test('reprendre délègue au dépôt', () async {
      await useCase.reprendre();

      verify(depot.reprendre).called(1);
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
      await useCase.definirVolume(actif: false);

      verify(() => depot.definirVolume(actif: false)).called(1);
    });
  });
}
