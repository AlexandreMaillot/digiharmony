import 'package:digiharmony_app/bienvenue/bienvenue_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hydrated_storage.dart';

void main() {
  group('BienvenueCubit', () {
    late MockStorage storage;

    setUp(() {
      storage = initMockHydratedStorage();
    });

    test('OB-1 : état initial = false', () {
      expect(BienvenueCubit().state, isFalse);
    });

    test('OB-2 : complete() émet true', () {
      final cubit = BienvenueCubit()..complete();
      expect(cubit.state, isTrue);
    });

    test('OB-3 : round-trip toJson/fromJson restitue true', () {
      final cubit = BienvenueCubit();
      final json = cubit.toJson(true);
      expect(cubit.fromJson(json), isTrue);
    });

    test('OB-4 : hydratation depuis storage {completed: true}', () {
      // storageToken = storagePrefix (runtimeType) + id
      // => 'BienvenueCubit' + 'bienvenue'.
      when(() => storage.read('BienvenueCubitbienvenue')).thenReturn(
        <String, dynamic>{'completed': true},
      );
      expect(BienvenueCubit().state, isTrue);
    });

    test('OB-5 : la clé de stockage est "bienvenue"', () {
      expect(BienvenueCubit().id, 'bienvenue');
    });

    test('estBienvenueVue() reflète l état courant', () {
      final cubit = BienvenueCubit();
      expect(cubit.estBienvenueVue(), isFalse);
      cubit.complete();
      expect(cubit.estBienvenueVue(), isTrue);
    });
  });
}
