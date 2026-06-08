import 'package:digiharmony_app/bootstrap.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'helpers/hydrated_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BOOT-1/BOOT-3/BOOT-4 : storage prêt avant builder, '
      'observer en place, db unique fournie', (tester) async {
    Object? storageDuringBuild;
    AppDatabase? providedDb;
    final mockStorage = MockStorage();

    await bootstrap(
      (database) {
        // Au moment où builder est appelé, le storage doit déjà être prêt.
        storageDuringBuild = HydratedBloc.storage;
        providedDb = database;
        return const SizedBox.shrink();
      },
      storageBuilder: () async => mockStorage,
      databaseBuilder: () => AppDatabase.forTesting(NativeDatabase.memory()),
    );
    await tester.pump();

    expect(storageDuringBuild, same(mockStorage));
    expect(providedDb, isNotNull);
    expect(Bloc.observer, isA<AppBlocObserver>());

    await providedDb?.close();
  });
}
