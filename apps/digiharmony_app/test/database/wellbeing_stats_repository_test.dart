import 'package:digiharmony_app/database/base_de_donnees.dart';
import 'package:digiharmony_app/database/depot_stats_bien_etre.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BaseDeDonnees db;
  late DepotStatsBienEtre repository;

  setUp(() {
    db = BaseDeDonnees.forTesting(NativeDatabase.memory());
    repository = DepotDriftStatsBienEtre(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DepotDriftStatsBienEtre', () {
    test('recordCompletedSession increments count per exercise', () async {
      await repository.recordCompletedSession('breathing');
      await repository.recordCompletedSession('breathing');
      await repository.recordCompletedSession('senses');

      expect(await repository.watchCompletedCount('breathing').first, 2);
      expect(await repository.watchCompletedCount('senses').first, 1);
      expect(await repository.watchCompletedCount('stretch').first, 0);
    });

    test('different exerciseIds do not collide', () async {
      await repository.recordCompletedSession('detox');
      expect(await repository.watchCompletedCount('detox').first, 1);
      expect(await repository.watchCompletedCount('breathing').first, 0);
    });
  });
}
