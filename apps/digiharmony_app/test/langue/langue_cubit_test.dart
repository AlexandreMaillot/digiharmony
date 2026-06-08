import 'dart:ui';

import 'package:digiharmony_app/langue/langue_cubit.dart';
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

  test('defaults to a supported device locale', () {
    final cubit = LangueCubit(deviceLocale: const Locale('fr'));
    expect(cubit.state.languageCode, 'fr');
  });

  test('falls back to en when device locale is unsupported', () {
    final cubit = LangueCubit(deviceLocale: const Locale('de'));
    expect(cubit.state.languageCode, 'en');
  });

  test('setLocale switches to a supported locale', () {
    final cubit = LangueCubit(deviceLocale: const Locale('en'))
      ..setLocale(const Locale('el'));
    expect(cubit.state.languageCode, 'el');
  });

  test('setLocale ignores unsupported locales', () {
    final cubit = LangueCubit(deviceLocale: const Locale('en'))
      ..setLocale(const Locale('zz'));
    expect(cubit.state.languageCode, 'en');
  });

  test('fromJson restores a supported locale, repli en otherwise', () {
    final cubit = LangueCubit(deviceLocale: const Locale('en'));
    expect(
      cubit.fromJson(<String, dynamic>{'languageCode': 'tr'}).languageCode,
      'tr',
    );
    expect(
      cubit.fromJson(<String, dynamic>{'languageCode': 'zz'}).languageCode,
      'en',
    );
  });
}
