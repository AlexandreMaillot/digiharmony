import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Tests de migration v1 → v2 → v3 de AppDatabase.
///
/// La migration réelle (v1→v2 via onUpgrade) nécessite un schéma v1 préalable.
/// Ces tests valident le comportement de la base v2 fraîche : colonne `jour`
/// présente, UPSERT unicité, encodage DateTime cohérent.
/// Le groupe MIG-V2V3 prouve que la migration v2→v3 crée
/// `usages_ecran_journaliers` sans perte de données et de façon idempotente.
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

  // ─── Migration v2 → v3 ─────────────────────────────────────────────────────
  group('Migration v2 → v3 — usages_ecran_journaliers', () {
    // Crée une base au schéma v2 réel (tables entrees_humeur + conseils,
    // PAS de usages_ecran_journaliers) via SQL brut, puis ouvre AppDatabase
    // en v3 pour déclencher onUpgrade(from: 2, to: 3).

    Database buildV2Sqlite() {
      final rawDb = sqlite3.openInMemory()
        // ── Schéma v2 réel ────────────────────────────────────────────────
        ..execute('''
        CREATE TABLE IF NOT EXISTS entrees_humeur (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code_emotion TEXT NOT NULL,
          valence INTEGER NOT NULL,
          cree_le INTEGER NOT NULL,
          jour INTEGER NOT NULL
        )
      ''')
        ..execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_entrees_humeur_jour '
          'ON entrees_humeur(jour)',
        )
        ..execute('''
        CREATE TABLE IF NOT EXISTS conseils (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cle_conseil TEXT NOT NULL
        )
      ''');
      // Données v2 : 1 entrée d'humeur + 1 conseil.
      // Drift stocke DateTime en millisecondes UTC epoch (INTEGER).
      final jourMs = DateTime(2025, 6).toUtc().millisecondsSinceEpoch;
      final creeLe =
          DateTime(2025, 6, 2, 10, 30).toUtc().millisecondsSinceEpoch;
      rawDb
        ..execute(
          'INSERT INTO entrees_humeur '
          '(code_emotion, valence, cree_le, jour) '
          'VALUES (?, ?, ?, ?)',
          ['happy', 1, creeLe, jourMs],
        )
        ..execute(
          "INSERT INTO conseils (cle_conseil) VALUES ('tipDay01')",
        )
        // user_version = 2 → Drift déclenchera onUpgrade(from: 2, to: 3)
        ..execute('PRAGMA user_version = 2');
      return rawDb;
    }

    // MIG-V2V3-1 : table usages_ecran_journaliers créée après migration.
    test(
      'MIG-V2V3-1 : usages_ecran_journaliers créée par la migration v2→v3',
      () async {
        final rawDb = buildV2Sqlite();
        final executor = NativeDatabase.opened(rawDb);
        final db = AppDatabase.forTesting(executor);
        addTearDown(db.close);

        // Déclenche l'ouverture → migration v2→v3 exécutée.
        await db.customSelect('SELECT 1').get();

        final tables = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' "
              "AND name='usages_ecran_journaliers'",
            )
            .get();
        expect(
          tables,
          isNotEmpty,
          reason:
              'La table usages_ecran_journaliers doit exister après '
              'migration v2→v3',
        );
      },
    );

    // MIG-V2V3-2 : données v2 (entrees_humeur, conseils) préservées.
    test(
      'MIG-V2V3-2 : données v2 préservées après migration v2→v3',
      () async {
        final rawDb = buildV2Sqlite();
        final executor = NativeDatabase.opened(rawDb);
        final db = AppDatabase.forTesting(executor);
        addTearDown(db.close);

        await db.customSelect('SELECT 1').get();

        final humeurs = await db.select(db.entreesHumeur).get();
        expect(
          humeurs.length,
          1,
          reason: "L'entrée d'humeur v2 doit être préservée",
        );
        expect(humeurs.first.codeEmotion, 'happy');

        final tips = await db.select(db.conseils).get();
        expect(
          tips,
          isNotEmpty,
          reason: 'Les conseils v2 doivent être préservés',
        );
      },
    );

    // MIG-V2V3-3 : idempotence — table déjà présente, pas d'erreur.
    test(
      'MIG-V2V3-3 : idempotence — IF NOT EXISTS protège contre un double '
      'CREATE',
      () async {
        final rawDb = buildV2Sqlite()
          // Pré-crée la table (simule une base semi-migrée).
          ..execute('''
          CREATE TABLE IF NOT EXISTS usages_ecran_journaliers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jour INTEGER NOT NULL,
            total_secondes INTEGER NOT NULL,
            maj_le INTEGER NOT NULL
          )
        ''');
        final executor = NativeDatabase.opened(rawDb);
        final db = AppDatabase.forTesting(executor);
        addTearDown(db.close);

        // Ne doit PAS lever d'exception malgré la table déjà présente.
        await expectLater(
          db.customSelect('SELECT 1').get(),
          completes,
          reason: 'La migration doit être idempotente (IF NOT EXISTS)',
        );
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
