import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests de l'historique journalier du temps d'écran (schéma v3).
void main() {
  group('UsagesEcranJournaliers (DEC-TE-04 révisé)', () {
    test('TE-DB-1 : UPSERT du jour → 1 ligne, total persisté', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.enregistrerUsageDuJour(const Duration(minutes: 30));
      final hist = await db.observerHistoriqueUsage().first;

      expect(hist, hasLength(1));
      expect(hist.first.totalSecondes, 30 * 60);
    });

    test('TE-DB-2 : 2 UPSERT le même jour → 1 ligne (dernier total)', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime.now();
      await db.enregistrerUsageDuJour(
        const Duration(minutes: 30),
        maintenant: now,
      );
      await db.enregistrerUsageDuJour(
        const Duration(minutes: 45),
        maintenant: now,
      );

      final hist = await db.observerHistoriqueUsage().first;
      expect(hist, hasLength(1));
      expect(hist.first.totalSecondes, 45 * 60);
    });

    test('TE-DB-3 : 2 jours distincts → 2 lignes triées', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime.now();
      final hier = now.subtract(const Duration(days: 1));
      await db.enregistrerUsageDuJour(
        const Duration(minutes: 10),
        maintenant: hier,
      );
      await db.enregistrerUsageDuJour(
        const Duration(minutes: 20),
        maintenant: now,
      );

      final hist = await db.observerHistoriqueUsage().first;
      expect(hist, hasLength(2));
      // Tri croissant : hier (10 min) avant aujourd'hui (20 min).
      expect(hist.first.totalSecondes, 10 * 60);
      expect(hist.last.totalSecondes, 20 * 60);
    });
  });
}
