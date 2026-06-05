import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hydrated_storage.dart';

void main() {
  group('LocaleBloc', () {
    late MockStorage storage;

    setUp(() {
      storage = initMockHydratedStorage();
    });

    test('LC-1 : état initial = null (suit la langue système)', () {
      expect(LocaleBloc().state.locale, isNull);
    });

    blocTest<LocaleBloc, LocaleState>(
      'LC-2 : LocaleChange(fr) émet LocaleState(Locale(fr))',
      build: LocaleBloc.new,
      act: (bloc) => bloc.add(const LocaleChange(Locale('fr'))),
      expect: () => [const LocaleState(locale: Locale('fr'))],
    );

    blocTest<LocaleBloc, LocaleState>(
      'LC-3 : LocaleSysteme() depuis fr émet LocaleState(null)',
      build: LocaleBloc.new,
      act: (bloc) {
        bloc
          ..add(const LocaleChange(Locale('fr')))
          ..add(const LocaleSysteme());
      },
      expect: () => [
        const LocaleState(locale: Locale('fr')),
        const LocaleState(),
      ],
    );

    test('LC-4/LC-5 : round-trip toJson/fromJson pour el', () {
      final bloc = LocaleBloc();
      final json = bloc.toJson(const LocaleState(locale: Locale('el')));
      expect(json, isNotNull);
      expect(json!['languageCode'], 'el');
      expect(bloc.fromJson(json).locale, const Locale('el'));
    });

    test('LC-6 : hydratation depuis storage {languageCode: it}', () {
      when(() => storage.read(any())).thenReturn(
        <String, dynamic>{'languageCode': 'it'},
      );
      expect(LocaleBloc().state.locale, const Locale('it'));
    });

    test('LC-7 : langue non supportée -> repli sûr null', () {
      final bloc = LocaleBloc();
      expect(
        bloc.fromJson(<String, dynamic>{'languageCode': 'de'}).locale,
        isNull,
      );
    });

    blocTest<LocaleBloc, LocaleState>(
      'LC-8 : les 8 langues supportées sont acceptées',
      build: LocaleBloc.new,
      act: (bloc) {
        const langues = ['en', 'fr', 'el', 'it', 'ro', 'tr', 'es', 'mk'];
        for (final code in langues) {
          bloc.add(LocaleChange(Locale(code)));
        }
      },
      verify: (bloc) {
        expect(bloc.state.locale, isNotNull);
      },
    );

    test('LocaleState.copyWith : sentinelle null fonctionne', () {
      const etat = LocaleState(locale: Locale('fr'));
      final copie = etat.copyWith(locale: null);
      expect(copie.locale, isNull);
    });

    test('LocaleState.copyWith : sans arg conserve la locale', () {
      const etat = LocaleState(locale: Locale('fr'));
      final copie = etat.copyWith();
      expect(copie.locale, const Locale('fr'));
    });

    test('LocaleState Equatable : égalité structurelle', () {
      expect(
        const LocaleState(locale: Locale('fr')),
        const LocaleState(locale: Locale('fr')),
      );
    });
  });
}
