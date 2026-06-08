// Les imports etirement/donnees et etirement/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/etirement/donnees/depot_audio_etirement.dart';
import 'package:digiharmony_app/pages/etirement/domaine/usecase/gerer_audio_etirement_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDepot extends Mock implements DepotAudioEtirement {}

void main() {
  setUpAll(() => registerFallbackValue(IdSegmentEtirement.anchor));

  group('GererAudioEtirementUseCase', () {
    late _MockDepot depot;
    late GererAudioEtirementUseCase useCase;

    setUp(() {
      depot = _MockDepot();
      useCase = GererAudioEtirementUseCase(depot: depot);
      when(() => depot.jouerSegment(any())).thenAnswer((_) async {});
      when(depot.mettreEnPause).thenAnswer((_) async {});
      when(depot.reprendre).thenAnswer((_) async {});
      when(depot.arreter).thenAnswer((_) async {});
      when(depot.liberer).thenAnswer((_) async {});
      when(
        () => depot.definirVolume(actif: any(named: 'actif')),
      ).thenAnswer((_) async {});
    });

    test('jouerSegment délègue au dépôt avec le bon identifiant', () async {
      await useCase.jouerSegment(IdSegmentEtirement.neckShoulders);

      verify(
        () => depot.jouerSegment(IdSegmentEtirement.neckShoulders),
      ).called(1);
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
