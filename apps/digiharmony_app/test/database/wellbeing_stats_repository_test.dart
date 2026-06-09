import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DepotStatsBienEtre repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DepotDriftStatsBienEtre(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DepotDriftStatsBienEtre', () {
    test('enregistrerSeance incrémente le compteur par exercice', () async {
      await repository.enregistrerSeance('breathing');
      await repository.enregistrerSeance('breathing');
      await repository.enregistrerSeance('senses');

      expect(await repository.observerNombreSeances('breathing').first, 2);
      expect(await repository.observerNombreSeances('senses').first, 1);
      expect(await repository.observerNombreSeances('stretch').first, 0);
    });

    test('exerciceIds distincts ne se heurtent pas', () async {
      await repository.enregistrerSeance('detox');
      expect(await repository.observerNombreSeances('detox').first, 1);
      expect(await repository.observerNombreSeances('breathing').first, 0);
    });
  });
}
