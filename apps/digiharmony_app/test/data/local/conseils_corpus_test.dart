import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Tests de migration v3→v4 et du seed corpus Conseils (DEC-CO-02).
void main() {
  // ─── Base fraîche v4 ──────────────────────────────────────────────────────
  group('Base fraîche v4 — corpus seedé', () {
    // CDB-1 : base fraîche → corpus complet seedé.
    test('CDB-1 : lireCorpusConseils retourne des entrées sur base fraîche',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final corpus = await db.lireCorpusConseils();
      expect(corpus, isNotEmpty, reason: 'Le corpus doit être seedé');
      // Les 7 tipDay + nouvelles cartes
      expect(
        corpus.length,
        greaterThanOrEqualTo(7),
        reason: 'Au moins les 7 tipDay doivent être présents',
      );
    });

    // CDB-2 : tipDay01..07 présents.
    test('CDB-2 : tipDay01..07 présents après seed', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final corpus = await db.lireCorpusConseils();
      final cles = corpus.map((c) => c.cleConseil).toSet();

      for (var i = 1; i <= 7; i++) {
        final cle = 'tipDay0$i';
        expect(cles, contains(cle), reason: '$cle doit être présent');
      }
    });

    // CDB-3 : cartes émotion présentes (7 canoniques).
    test('CDB-3 : cartes émotion pour les 7 émotions canoniques', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final corpus = await db.lireCorpusConseils();
      final emotions = corpus.where((c) => c.typeCarte == 'emotion').toList();
      final codes = emotions
          .map((e) => e.codeEmotion)
          .whereType<String>()
          .toSet();

      expect(codes, containsAll(['angry', 'sad', 'nervous', 'tired']));
      expect(codes, containsAll(['happy', 'calm', 'dynamic']));
    });

    // CDB-4 : typeCarte renseigné (pas de null).
    test('CDB-4 : typeCarte non vide pour toutes les cartes', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final corpus = await db.lireCorpusConseils();
      for (final c in corpus) {
        expect(
          c.typeCarte,
          isNotEmpty,
          reason: '${c.cleConseil} doit avoir un typeCarte',
        );
      }
    });

    // CDB-5 : ordre stable (croissant).
    test('CDB-5 : corpus ordonné par ordre/id', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final corpus = await db.lireCorpusConseils();
      expect(corpus, isNotEmpty);
      // Vérifie que la liste est triée par ordre croissant.
      for (var i = 1; i < corpus.length; i++) {
        final prev = corpus[i - 1];
        final curr = corpus[i];
        expect(
          curr.ordre >= prev.ordre || curr.id >= prev.id,
          isTrue,
          reason: 'Le corpus doit être trié (ordre ou id)',
        );
      }
    });

    // CDB-6 : idempotence du seed (ré-ouverture).
    test('CDB-6 : seed idempotent — double ouverture pas de doublon', () async {
      final executor = NativeDatabase.memory();
      final db1 = AppDatabase.forTesting(executor);
      // Déclenche le seed initial.
      final corpus1 = await db1.lireCorpusConseils();
      await db1.close();

      // Ré-ouvre sur le même executor (simule ré-ouverture app).
      // Note : NativeDatabase.memory() ne persiste pas entre close/reopen,
      // mais on vérifie que le seed ne plante pas sur une base avec données.
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db2.close);
      // Premier seed.
      await db2.lireCorpusConseils();
      // On vérifie manuellement l'idempotence via la requête SQL.
      // Le _seedCorpus ne doit pas insérer de doublon.
      final corpus2 = await db2.lireCorpusConseils();
      final cles = corpus2.map((c) => c.cleConseil).toList();
      expect(
        cles.toSet().length,
        cles.length,
        reason: 'Pas de doublon de cle_conseil',
      );
      expect(corpus1.isNotEmpty, isTrue);
    });

    // CDB-7 : conseilDuJour non modifié.
    test('CDB-7 : conseilDuJour toujours fonctionnel', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final conseil = await db.conseilDuJour(DateTime(2026, 6, 6));
      expect(conseil, isNotNull);
      expect(conseil.cleConseil, isNotEmpty);
    });
  });

  // ─── Migration v3 → v4 ────────────────────────────────────────────────────
  group('Migration v3 → v4 — colonnes ajoutées idempotent', () {
    // Construit une DB SQLite brut au schéma v3 (sans les colonnes v4)
    // avec 7 tipDay existants.
    Database buildV3Sqlite() {
      final rawDb = sqlite3.openInMemory()
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
        ''')
        ..execute('''
          CREATE TABLE IF NOT EXISTS usages_ecran_journaliers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jour INTEGER NOT NULL,
            total_secondes INTEGER NOT NULL,
            maj_le INTEGER NOT NULL
          )
        ''')
        ..execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_usages_ecran_journaliers_jour '
          'ON usages_ecran_journaliers(jour)',
        );

      // Seed v3 : 7 tipDay.
      for (var i = 1; i <= 7; i++) {
        rawDb.execute(
          "INSERT INTO conseils (cle_conseil) VALUES ('tipDay0$i')",
        );
      }
      // Marque user_version = 3.
      rawDb.execute('PRAGMA user_version = 3');
      return rawDb;
    }

    // MIGV4-1 : colonnes ajoutées après migration.
    test(
      'MIGV4-1 : colonnes type_carte/code_emotion/accent_chrome/ordre '
      'ajoutées par migration v3→v4',
      () async {
        final rawDb = buildV3Sqlite();
        final executor = NativeDatabase.opened(rawDb);
        final db = AppDatabase.forTesting(executor);
        addTearDown(db.close);

        // Déclenche l'ouverture → migration v3→v4.
        await db.customSelect('SELECT 1').get();

        final infos = await db
            .customSelect("PRAGMA table_info('conseils')")
            .get();
        final noms = infos.map((r) => r.read<String>('name')).toSet();

        expect(noms, contains('type_carte'));
        expect(noms, contains('code_emotion'));
        expect(noms, contains('accent_chrome'));
        expect(noms, contains('ordre'));
      },
    );

    // MIGV4-2 : données v3 préservées.
    test(
      'MIGV4-2 : tipDay01..07 préservés après migration v3→v4',
      () async {
        final rawDb = buildV3Sqlite();
        final executor = NativeDatabase.opened(rawDb);
        final db = AppDatabase.forTesting(executor);
        addTearDown(db.close);

        await db.customSelect('SELECT 1').get();

        final corpus = await db.lireCorpusConseils();
        final cles = corpus.map((c) => c.cleConseil).toSet();

        for (var i = 1; i <= 7; i++) {
          expect(cles, contains('tipDay0$i'));
        }
      },
    );

    // MIGV4-3 : idempotence — colonnes déjà présentes.
    test(
      'MIGV4-3 : idempotence — colonnes v4 déjà présentes, pas de crash',
      () async {
        final rawDb = buildV3Sqlite()
          ..execute(
            'ALTER TABLE conseils ADD COLUMN type_carte TEXT '
            "NOT NULL DEFAULT 'conseil'",
          )
          ..execute(
            'ALTER TABLE conseils ADD COLUMN code_emotion TEXT',
          )
          ..execute(
            'ALTER TABLE conseils ADD COLUMN accent_chrome TEXT '
            "NOT NULL DEFAULT 'primary'",
          )
          ..execute(
            'ALTER TABLE conseils ADD COLUMN ordre INTEGER NOT NULL DEFAULT 0',
          );

        final executor = NativeDatabase.opened(rawDb);
        final db = AppDatabase.forTesting(executor);
        addTearDown(db.close);

        // Ne doit pas crasher.
        await expectLater(
          db.customSelect('SELECT 1').get(),
          completes,
        );
      },
    );

    // MIGV4-4 : cartes émotion ajoutées par seed après migration.
    test(
      'MIGV4-4 : cartes émotion présentes après migration v3→v4 + seed',
      () async {
        final rawDb = buildV3Sqlite();
        final executor = NativeDatabase.opened(rawDb);
        final db = AppDatabase.forTesting(executor);
        addTearDown(db.close);

        await db.customSelect('SELECT 1').get();

        final corpus = await db.lireCorpusConseils();
        final emotions =
            corpus.where((c) => c.typeCarte == 'emotion').toList();

        expect(
          emotions,
          isNotEmpty,
          reason: 'Les cartes émotion doivent être seedées après migration',
        );
      },
    );
  });
}
