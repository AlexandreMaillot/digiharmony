import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Journal d'humeur — table LECTURE et ÉCRITURE (US #6 « Noter mon humeur »).
///
/// Schéma v2 : colonne `jour` normalisée (minuit local) + index unique pour
/// garantir une entrée max par jour (UPSERT, DEC-SH-001).
@DataClassName('EntreeHumeur')
class EntreesHumeur extends Table {
  @override
  String get tableName => 'entrees_humeur';

  /// Identifiant auto-incrémenté.
  IntColumn get id => integer().autoIncrement()();

  /// Code stable de l'émotion (aligné `MoodColors.byKey`).
  TextColumn get codeEmotion => text().named('code_emotion')();

  /// Valence : >= 0 positive/neutre, < 0 négative (DEC-SH-002).
  ///
  /// Sert au futur compteur « 7 émotions négatives consécutives », dérivé de
  /// Drift (DEC-001), jamais dupliqué dans HydratedBloc.
  IntColumn get valence => integer()();

  /// Horodatage local de création.
  DateTimeColumn get creeLe => dateTime().named('cree_le')();

  /// Jour normalisé (minuit local) — clé d'unicité quotidienne (v2).
  ///
  /// Stocké comme DateTime à 00:00:00 local. Index UNIQUE généré par Drift
  /// via [uniqueKeys]. Permet l'UPSERT par jour (DEC-SH-001).
  DateTimeColumn get jour => dateTime().named('jour')();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {jour},
  ];
}

/// Conseils bienveillants — dataset local seedé, rotation quotidienne.
@DataClassName('Conseil')
class Conseils extends Table {
  /// Identifiant auto-incrémenté.
  IntColumn get id => integer().autoIncrement()();

  /// Clé i18n du conseil (le texte traduit vit dans les ARB).
  TextColumn get cleConseil => text().named('cle_conseil')();
}

/// Base de données locale unique de l'application (SQLite via Drift).
///
/// Persistance 100 % locale, zéro réseau. Le journal d'humeur vit
/// **uniquement** ici (DEC-001/002) ; l'état A/B est dérivé via `watch()`.
@DriftDatabase(tables: [EntreesHumeur, Conseils])
class AppDatabase extends _$AppDatabase {
  /// Ouvre la base de production (fichier dans le dossier documents).
  AppDatabase() : super(_openConnection());

  /// Construit une base à partir d'un executor donné (tests : mémoire).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  /// Référence Unix epoch pour la rotation déterministe des conseils.
  static final DateTime _epoch = DateTime(1970);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedConseils();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Ajoute `jour` seulement si absente (idempotence).
        // Sur une base semi-migrée, SQLite lèverait
        // "duplicate column name: jour" → crash DB.
        final infos = await customSelect(
          "PRAGMA table_info('entrees_humeur')",
        ).get();
        final aDejaJour = infos.any((r) => r.read<String>('name') == 'jour');
        if (!aDejaJour) {
          await m.addColumn(entreesHumeur, entreesHumeur.jour);
        }
        // Backfill : dérive `jour` depuis `cree_le`.
        // Drift sérialise DateTime en epoch unix (microsecondes UTC).
        // On recalcule le minuit local en secondes * 1000 (format Drift).
        // Formule : jour_ms = (cree_le / 86400000000) * 86400000000
        // => troncature au jour UTC (acceptable pour backfill — données
        // existantes sont en test uniquement, pas en prod).
        await customStatement(
          'UPDATE entrees_humeur '
          'SET jour = (cree_le / 86400000000) * 86400000000',
        );
        // Déduplication avant index unique : ne garder que la dernière
        // entrée par jour (max cree_le), supprimer les doublons éventuels.
        await customStatement(
          'DELETE FROM entrees_humeur WHERE id NOT IN ( '
          ' SELECT id FROM entrees_humeur e1 '
          ' WHERE cree_le = ( '
          '  SELECT MAX(cree_le) FROM entrees_humeur e2 '
          '  WHERE e2.jour = e1.jour '
          ' ) '
          ')',
        );
        // Index unique sur `jour`.
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_entrees_humeur_jour '
          'ON entrees_humeur(jour)',
        );
      }
    },
    beforeOpen: (details) async {
      // Idempotence : seed si la table est vide (ré-ouverture).
      await _seedConseils();
    },
  );

  /// Seed des conseils (~7), idempotent : ne fait rien si déjà peuplé.
  Future<void> _seedConseils() async {
    final count = await conseils.count().getSingle();
    if (count > 0) return;
    await batch((b) {
      b.insertAll(
        conseils,
        const <ConseilsCompanion>[
          ConseilsCompanion(cleConseil: Value('tipDay01')),
          ConseilsCompanion(cleConseil: Value('tipDay02')),
          ConseilsCompanion(cleConseil: Value('tipDay03')),
          ConseilsCompanion(cleConseil: Value('tipDay04')),
          ConseilsCompanion(cleConseil: Value('tipDay05')),
          ConseilsCompanion(cleConseil: Value('tipDay06')),
          ConseilsCompanion(cleConseil: Value('tipDay07')),
        ],
      );
    });
  }

  // ─── Lecture ─────────────────────────────────────────────────────────────

  /// Dernière entrée d'humeur du jour courant, réactif.
  ///
  /// Émet `null` si aucune entrée aujourd'hui. Bornes `[minuit, minuit+1j)`,
  /// tri `creeLe DESC LIMIT 1`. La borne supérieure est **exclue** dans le
  /// `where` (`creeLe >= start AND creeLe < end`) — sans post-filtrage.
  Stream<EntreeHumeur?> observerDerniereHumeurDuJour() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(entreesHumeur)
          ..where(
            (t) =>
                t.creeLe.isBiggerOrEqualValue(start) &
                t.creeLe.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.creeLe)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Entrées d'humeur de la semaine contenant [jourReference], réactif.
  ///
  /// Bornes `[lundi 00:00, lundi+7j)` en heure locale, tri `creeLe ASC`.
  /// La borne haute est **exclue** (`isSmallerThanValue(end)`) —
  /// pas de post-filtrage (DEC-J-11).
  Stream<List<EntreeHumeur>> observerEntreesDeLaSemaine(
    DateTime jourReference,
  ) {
    final jour = DateTime(
      jourReference.year,
      jourReference.month,
      jourReference.day,
    );
    // Lundi de la semaine (weekday : lundi = 1, dimanche = 7).
    final start = jour.subtract(Duration(days: jour.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return (select(entreesHumeur)
          ..where(
            (t) =>
                t.creeLe.isBiggerOrEqualValue(start) &
                t.creeLe.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.creeLe)]))
        .watch();
  }

  /// Entrées d'humeur du mois de [jourReference], réactif.
  ///
  /// Bornes `[1er du mois 00:00, 1er du mois suivant 00:00)` en heure locale,
  /// tri `creeLe ASC`. La borne haute est **exclue** —
  /// pas de post-filtrage (DEC-J-11).
  Stream<List<EntreeHumeur>> observerEntreesDuMois(DateTime jourReference) {
    final start = DateTime(jourReference.year, jourReference.month);
    // Premier jour du mois suivant (gestion automatique du dépassement de mois
    // par le constructeur DateTime — ex. mois 12 → 13 devient janvier + 1 an).
    final end = DateTime(jourReference.year, jourReference.month + 1);
    return (select(entreesHumeur)
          ..where(
            (t) =>
                t.creeLe.isBiggerOrEqualValue(start) &
                t.creeLe.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.creeLe)]))
        .watch();
  }

  /// Conseil **déterministe** du jour [jour].
  ///
  /// `index = joursDepuisEpoch % nbConseils`, stable toute la journée,
  /// sans aléatoire ni stockage d'état.
  Future<Conseil> conseilDuJour(DateTime jour) async {
    final all = await (select(
      conseils,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    if (all.isEmpty) {
      throw StateError('Aucun conseil seedé dans la base.');
    }
    final jourNormalise = DateTime(jour.year, jour.month, jour.day);
    final joursDepuisEpoch = jourNormalise.difference(_epoch).inDays;
    final index = joursDepuisEpoch % all.length;
    return all[index];
  }

  // ─── Soutien ──────────────────────────────────────────────────────────────

  /// Seuil de déclenchement du soutien : 7 saisies négatives consécutives.
  ///
  /// Source unique du seuil (DEC-SOP-005) ; partagé avec
  /// [EvaluateurSoutien.seuil] qui y fait référence.
  static const int seuilSoutien = 7;

  /// Compte les saisies négatives consécutives EN PARTANT DE LA PLUS RÉCENTE.
  ///
  /// Lit le journal trié par date décroissante et additionne tant que la valence
  /// est < 0 ; s'arrête à la première saisie positive/neutre. Les jours sans
  /// saisie n'apparaissent pas dans le journal → naturellement ignorés.
  /// Dérivé de Drift (DEC-001), jamais dupliqué dans HydratedBloc.
  Future<int> compterSaisiesNegativesConsecutives() async {
    final entrees =
        await (select(entreesHumeur)
              ..orderBy([(t) => OrderingTerm.desc(t.creeLe)]))
            .get();

    var compteur = 0;
    for (final entree in entrees) {
      if (entree.valence < 0) {
        compteur++;
      } else {
        break;
      }
    }
    return compteur;
  }

  /// Sucre : déclenchement potentiel du soutien (compteur >= [seuilSoutien]).
  ///
  /// N'inclut PAS l'anti-relance (portée par [SoutienBloc]).
  Future<bool> aDeclencherSoutien() async {
    return await compterSaisiesNegativesConsecutives() >= seuilSoutien;
  }

  // ─── Écriture ─────────────────────────────────────────────────────────────

  /// UPSERT de l'humeur du jour courant (DEC-SH-001/003).
  ///
  /// Écrase l'entrée existante du même jour (re-notation autorisée).
  /// Retourne l'entrée précédente du jour (ou null) avant écrasement,
  /// pour permettre l'annulation (restauration, DEC-SH-007).
  Future<EntreeHumeur?> enregistrerHumeurDuJour(String codeEmotion) async {
    final now = DateTime.now();
    final jourNormalise = DateTime(now.year, now.month, now.day);

    // Lire l'entrée existante du jour avant l'UPSERT.
    final ancienne =
        await (select(entreesHumeur)
              ..where((t) => t.jour.equals(jourNormalise))
              ..limit(1))
            .getSingleOrNull();

    // UPSERT : conflit sur l'index unique `jour` → update.
    // `DoUpdate` avec `target: [entreesHumeur.jour]` cible explicitement
    // la contrainte unique sur `jour` (DEC-SH-001).
    final companion = EntreesHumeurCompanion.insert(
      codeEmotion: codeEmotion,
      valence: valencePour(codeEmotion),
      creeLe: now,
      jour: jourNormalise,
    );
    await into(entreesHumeur).insert(
      companion,
      onConflict: DoUpdate(
        (_) => companion,
        target: [entreesHumeur.jour],
      ),
    );

    return ancienne;
  }

  /// Annule la dernière saisie selon le contexte (DEC-SH-007).
  ///
  /// - [ancienneEntree] != null → restaure l'ancienne valeur du jour.
  /// - [ancienneEntree] == null → supprime l'entrée du jour.
  Future<void> annulerDerniereSaisie({EntreeHumeur? ancienneEntree}) async {
    final now = DateTime.now();
    final jourCourant = DateTime(now.year, now.month, now.day);

    if (ancienneEntree != null) {
      // Restaure l'ancienne entrée (UPSERT ciblant `jour`).
      final restauree = EntreesHumeurCompanion.insert(
        codeEmotion: ancienneEntree.codeEmotion,
        valence: ancienneEntree.valence,
        creeLe: ancienneEntree.creeLe,
        jour: ancienneEntree.jour,
      );
      await into(entreesHumeur).insert(
        restauree,
        onConflict: DoUpdate(
          (_) => restauree,
          target: [entreesHumeur.jour],
        ),
      );
    } else {
      // Supprime l'entrée du jour.
      await (delete(
        entreesHumeur,
      )..where((t) => t.jour.equals(jourCourant))).go();
    }
  }
}

// ─── Helper de valence ─────────────────────────────────────────────────────

/// Valence déterministe pour un [codeEmotion] (DEC-SH-002).
///
/// Négative (< 0) : sad, angry, nervous, tired.
/// Positive/neutre (>= 0) : happy, calm, dynamic.
///
/// Fonction pure, testable isolément.
int valencePour(String codeEmotion) {
  switch (codeEmotion) {
    case 'sad':
    case 'angry':
    case 'nervous':
    case 'tired':
      return -1;
    case 'happy':
    case 'calm':
    case 'dynamic':
    default:
      return 1;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'digiharmony.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      // `busy_timeout` : si un verrou transitoire subsiste (fichiers WAL/SHM
      // résiduels après une suppression manuelle des données, ou handle de
      // l'instance précédente non libéré), SQLite réessaie pendant 5 s au lieu
      // de lever immédiatement « database is locked (code 5) » à la création
      // des tables (migration onCreate).
      setup: (db) => db.execute('PRAGMA busy_timeout = 5000;'),
    );
  });
}
