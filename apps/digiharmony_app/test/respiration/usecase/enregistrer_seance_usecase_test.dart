import 'package:digiharmony_app/pages/respiration/domaine/usecase/usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('EnregistrerSeanceBienEtreUseCase', () {
    late FakeDepotStatsBienEtre depot;
    late EnregistrerSeanceBienEtreUseCase useCase;

    setUp(() {
      depot = FakeDepotStatsBienEtre();
      useCase = EnregistrerSeanceBienEtreUseCase(depot: depot);
    });

    test('appeler enregistre la séance avec le bon exerciceId', () async {
      await useCase.appeler('breathing');

      expect(depot.recorded, contains('breathing'));
    });

    test('appeler plusieurs fois enregistre plusieurs fois', () async {
      await useCase.appeler('breathing');
      await useCase.appeler('breathing');

      expect(
        depot.recorded.where((e) => e == 'breathing').length,
        2,
      );
    });

    test('appeler avec un autre id enregistre le bon id', () async {
      await useCase.appeler('stretching');

      expect(depot.recorded, contains('stretching'));
      expect(depot.recorded, isNot(contains('breathing')));
    });
  });
}
