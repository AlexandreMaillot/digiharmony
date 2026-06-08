import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/detox/bloc/detox_config_bloc.dart';
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

  test('defaults to sea + 15 min', () {
    final bloc = DetoxConfigBloc();
    expect(bloc.state.ambianceId, IdAmbianceDetox.sea);
    expect(bloc.state.durationMinutes, 15);
  });

  test('DetoxAmbianceSelectionnee updates ambiance', () async {
    final bloc = DetoxConfigBloc()
      ..add(const DetoxAmbianceSelectionnee(IdAmbianceDetox.forest));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.ambianceId, IdAmbianceDetox.forest);
  });

  test('DetoxDureeSelectionnee updates duration', () async {
    final bloc = DetoxConfigBloc()..add(const DetoxDureeSelectionnee(5));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.durationMinutes, 5);
  });

  test('DetoxDureeSelectionnee ignores disallowed values', () async {
    final bloc = DetoxConfigBloc()..add(const DetoxDureeSelectionnee(7));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.durationMinutes, 15);
  });

  test('fromJson falls back to defaults on unknown values', () {
    final bloc = DetoxConfigBloc();
    final restored = bloc.fromJson(<String, dynamic>{
      'ambianceId': 'unknown',
      'durationMinutes': 99,
    });
    expect(restored!.ambianceId, IdAmbianceDetox.sea);
    expect(restored.durationMinutes, 15);
  });
}
