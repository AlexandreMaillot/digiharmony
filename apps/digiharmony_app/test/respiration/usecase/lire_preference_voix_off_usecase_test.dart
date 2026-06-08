import 'package:digiharmony_app/pages/respiration/domaine/usecase/usecase.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('LirePreferenceVoixOffUseCase', () {
    setUp(() {
      final storage = MockHydratedStorage();
      when(() => storage.read(any())).thenReturn(null);
      when(() => storage.write(any(), any<dynamic>()))
          .thenAnswer((_) async {});
      when(() => storage.delete(any())).thenAnswer((_) async {});
      when(storage.clear).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
    });

    test('retourne true quand la voix off est active', () async {
      final bloc = VoixOffBloc();
      // État initial = active: true, pas besoin d'event.
      final useCase = LirePreferenceVoixOffUseCase(voixOffBloc: bloc);

      expect(useCase.appeler(), isTrue);
      await bloc.close();
    });

    test('retourne false quand la voix off est inactive', () async {
      final bloc = VoixOffBloc()..add(const VoixOffDefinie(active: false));
      // Attendre le traitement de l'event.
      await Future<void>.delayed(Duration.zero);
      final useCase = LirePreferenceVoixOffUseCase(voixOffBloc: bloc);

      expect(useCase.appeler(), isFalse);
      await bloc.close();
    });
  });
}
