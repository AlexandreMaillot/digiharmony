import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

void main() {
  setUp(() {
    final storage = MockHydratedStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  group('VoixOffBloc', () {
    test('état initial est active: true', () {
      expect(VoixOffBloc().state, const VoixOffEtat(active: true));
    });

    blocTest<VoixOffBloc, VoixOffEtat>(
      'VoixOffBasculee bascule de true à false',
      build: VoixOffBloc.new,
      act: (bloc) => bloc.add(const VoixOffBasculee()),
      expect: () => [const VoixOffEtat(active: false)],
    );

    blocTest<VoixOffBloc, VoixOffEtat>(
      'VoixOffBasculee deux fois revient à true',
      build: VoixOffBloc.new,
      act: (bloc) => bloc
        ..add(const VoixOffBasculee())
        ..add(const VoixOffBasculee()),
      expect: () => [
        const VoixOffEtat(active: false),
        const VoixOffEtat(active: true),
      ],
    );

    blocTest<VoixOffBloc, VoixOffEtat>(
      'VoixOffDefinie force la valeur',
      build: VoixOffBloc.new,
      act: (bloc) => bloc.add(const VoixOffDefinie(active: false)),
      expect: () => [const VoixOffEtat(active: false)],
    );

    test('fromJson/toJson : round-trip preserves value', () {
      final bloc = VoixOffBloc();
      final json = bloc.toJson(const VoixOffEtat(active: false));
      final restored = bloc.fromJson(json!);

      expect(restored, const VoixOffEtat(active: false));
    });

    test('fromJson avec valeur manquante retourne active: true par défaut',
        () {
      final bloc = VoixOffBloc();
      final restored = bloc.fromJson(<String, dynamic>{});

      expect(restored, const VoixOffEtat(active: true));
    });
  });
}
