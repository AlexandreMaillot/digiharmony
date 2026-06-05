import 'package:digiharmony_app/locale/locale_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hydrated_storage.dart';

void main() {
  group('LocaleCubit', () {
    late MockStorage storage;

    setUp(() {
      storage = initMockHydratedStorage();
    });

    test('LC-1 : état initial = null (suit la langue système)', () {
      expect(LocaleCubit().state, isNull);
    });

    test('LC-2 : setLocale(fr) émet Locale(fr)', () {
      final cubit = LocaleCubit()..setLocale(const Locale('fr'));
      expect(cubit.state, const Locale('fr'));
    });

    test('LC-3 : useSystem() depuis fr émet null', () {
      final cubit = LocaleCubit()
        ..setLocale(const Locale('fr'))
        ..useSystem();
      expect(cubit.state, isNull);
    });

    test('LC-4/LC-5 : round-trip toJson/fromJson pour el', () {
      final cubit = LocaleCubit();
      final json = cubit.toJson(const Locale('el'));
      expect(json, isNotNull);
      expect(json!['languageCode'], 'el');
      expect(cubit.fromJson(json), const Locale('el'));
    });

    test('LC-6 : hydratation depuis storage {languageCode: it}', () {
      when(() => storage.read(any())).thenReturn(
        <String, dynamic>{'languageCode': 'it'},
      );
      expect(LocaleCubit().state, const Locale('it'));
    });

    test('LC-7 : langue non supportée -> repli sûr null', () {
      final cubit = LocaleCubit();
      expect(cubit.fromJson(<String, dynamic>{'languageCode': 'de'}), isNull);
    });

    test('LC-8 : les 8 langues supportées sont acceptées', () {
      const langues = ['en', 'fr', 'el', 'it', 'ro', 'tr', 'es', 'mk'];
      for (final code in langues) {
        final cubit = LocaleCubit()..setLocale(Locale(code));
        expect(cubit.state, Locale(code), reason: 'langue $code rejetée');
      }
    });
  });
}
