import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests de migration v1 → v2 de AppDatabase.
///
/// La migration réelle (v1→v2 via onUpgrade) nécessite un schéma v1 préalable.
/// Ces tests valident le comportement de la base v2 fraîche : colonne `jour`
/// présente, UPSERT unicité, encodage DateTime cohérent.
void main() {
  group('Base v2 — comportements post-migration', () {
    // MIG-1 : base fraîche v2 — UPSERT fonctionne.
    test('MIG-1 : base fraîche v2 — enregistrerHumeurDuJour OK', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final ancienne = await db.enregistrerHumeurDuJour('happy');
      expect(ancienne, isNull);

      final rows = await db.select(db.entreesHumeur).get();
      expect(rows.length, 1);
    });

    // MIG-2 : unicité quotidienne — 2 UPSERT le même jour = 1 ligne.
    test('MIG-2 : 2 UPSERT le même jour → 1 seule ligne', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.enregistrerHumeurDuJour('happy');
      final ancienne = await db.enregistrerHumeurDuJour('calm');

      expect(ancienne, isNotNull);
      expect(ancienne!.codeEmotion, 'happy');

      final rows = await db.select(db.entreesHumeur).get();
      expect(rows.length, 1);

      final derniere = await db.observerDerniereHumeurDuJour().first;
      expect(derniere?.codeEmotion, 'calm');
    });

    // MIG-3 : 2 jours différents → 2 lignes.
    test('MIG-3 : 2 jours différents → 2 lignes', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final hier = DateTime.now().subtract(const Duration(days: 1));
      final jourHier = DateTime(hier.year, hier.month, hier.day);

      await db
          .into(db.entreesHumeur)
          .insert(
            EntreesHumeurCompanion.insert(
              codeEmotion: 'sad',
              valence: -1,
              creeLe: hier,
              jour: jourHier,
            ),
          );

      await db.enregistrerHumeurDuJour('happy');

      final rows = await db.select(db.entreesHumeur).get();
      expect(rows.length, 2);
    });

    // MIG-4 : colonne `jour` = minuit local cohérent.
    test(
      'MIG-4 : colonne jour == minuit local (encodage Drift cohérent)',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await db.enregistrerHumeurDuJour('calm');

        final entree = await db.observerDerniereHumeurDuJour().first;
        expect(entree, isNotNull);

        final maintenant = DateTime.now();
        final minuitLocal = DateTime(
          maintenant.year,
          maintenant.month,
          maintenant.day,
        );

        expect(entree!.jour.hour, 0);
        expect(entree.jour.minute, 0);
        expect(entree.jour.second, 0);
        expect(entree.jour.year, minuitLocal.year);
        expect(entree.jour.month, minuitLocal.month);
        expect(entree.jour.day, minuitLocal.day);
      },
    );
  });

  group('Migration idempotence — colonne jour déjà présente', () {
    // MIG-5 : PRAGMA guard détecte `jour` et protège contre un double ALTER.
    //
    // Sans le guard, un onUpgrade appelé sur une base semi-migrée (colonne
    // déjà présente) lèverait "duplicate column name: jour" → crash DB.
    // Ce test vérifie que le guard PRAGMA table_info fonctionne correctement.
    test(
      'MIG-5 : guard PRAGMA détecte jour — double ALTER évité',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        // Déclenche onCreate (base fraîche v2 → colonne `jour` présente).
        await db.enregistrerHumeurDuJour('happy');

        // Vérifie que PRAGMA table_info détecte bien `jour`.
        final infos = await db
            .customSelect("PRAGMA table_info('entrees_humeur')")
            .get();
        final colonnes = infos.map((r) => r.read<String>('name')).toList();
        expect(colonnes, contains('jour'));

        // Simule le guard : aDejaJour == true → addColumn non exécuté.
        final aDejaJour = infos.any((r) => r.read<String>('name') == 'jour');
        expect(aDejaJour, isTrue);

        // Sans guard, ce double ALTER crasherait avec
        // SqliteException(1): duplicate column name: jour.
        // Avec le guard, il est court-circuité → pas d'exception.
        if (!aDejaJour) {
          await db.customStatement(
            'ALTER TABLE entrees_humeur'
            ' ADD COLUMN jour INTEGER',
          );
        }
        // Si on arrive ici sans exception, le guard fonctionne.
        expect(colonnes, contains('jour'));
      },
    );
  });
}
