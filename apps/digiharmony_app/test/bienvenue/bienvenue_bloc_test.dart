import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/pages/bienvenue/bloc/bienvenue_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hydrated_storage.dart';

void main() {
  group('BienvenueBloc', () {
    late MockStorage storage;

    setUp(() {
      storage = initMockHydratedStorage();
    });

    test('OB-1 : état initial = false', () {
      expect(BienvenueBloc().state.estBienvenueVue, isFalse);
    });

    blocTest<BienvenueBloc, BienvenueState>(
      'OB-2 : BienvenueTerminee() émet estBienvenueVue = true',
      build: BienvenueBloc.new,
      act: (bloc) => bloc.add(const BienvenueTerminee()),
      expect: () => [const BienvenueState(estBienvenueVue: true)],
    );

    test('OB-3 : round-trip toJson/fromJson restitue true', () {
      final bloc = BienvenueBloc();
      final json = bloc.toJson(const BienvenueState(estBienvenueVue: true));
      expect(bloc.fromJson(json).estBienvenueVue, isTrue);
    });

    test('OB-4 : hydratation depuis storage {completed: true}', () {
      // storageToken = storagePrefix (runtimeType) + id
      // => 'BienvenueBloc' + 'bienvenue'.
      when(() => storage.read('BienvenueBlocbienvenue')).thenReturn(
        <String, dynamic>{'completed': true},
      );
      expect(BienvenueBloc().state.estBienvenueVue, isTrue);
    });

    test('OB-5 : la clé de stockage est "bienvenue"', () {
      expect(BienvenueBloc().id, 'bienvenue');
    });

    test('BienvenueState.copyWith : estBienvenueVue fonctionne', () {
      const etat = BienvenueState();
      final copie = etat.copyWith(estBienvenueVue: true);
      expect(copie.estBienvenueVue, isTrue);
    });

    test('BienvenueState Equatable : égalité structurelle', () {
      expect(
        const BienvenueState(estBienvenueVue: true),
        const BienvenueState(estBienvenueVue: true),
      );
    });
  });
}
