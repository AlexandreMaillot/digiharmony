import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Agrégat des séances bien-être terminées par type d'exercice.
///
/// Schéma v5 : table ajoutée pour suivre le nombre de séances par exercice.
/// 100 % locale, zéro collecte. Clé = `exercice_id`.
@DataClassName('SeanceBienEtre')
class SeancesBienEtre extends Table {
  @override
  String get tableName => 'wellbeing_stats';

  /// Identifiant d'exercice (ex. 'breathing', 'senses', 'stretch', 'detox').
  TextColumn get exerciceId => text().named('exercise_id')();

  /// Nombre de séances terminées.
  IntColumn get nombreSeances =>
      integer().named('completed_count').withDefault(const Constant(0))();

  /// Date de la dernière séance terminée (null si aucune).
  DateTimeColumn get derniereSeanceLe =>
      dateTime().named('last_completed_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {exerciceId};
}

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
///
/// Schéma v4 : colonnes structurelles ajoutées pour le deck de cartes Conseils.
/// Le texte des cartes vit dans les ARB (jamais dans cette table).
@DataClassName('Conseil')
class Conseils extends Table {
  /// Identifiant auto-incrémenté.
  IntColumn get id => integer().autoIncrement()();

  /// Clé i18n du conseil (le texte traduit vit dans les ARB).
  TextColumn get cleConseil => text().named('cle_conseil')();

  // ─── AJOUTS (schéma v4) ───

  /// Type de carte : 'rappel' | 'conseil' | 'emotion'.
  TextColumn get typeCarte =>
      text().named('type_carte').withDefault(const Constant('conseil'))();

  /// Code émotion canonique si typeCarte == 'emotion' (sinon null).
  ///
  /// ∈ emotionsCanoniques ('happy','calm','dynamic','sad','angry','nervous',
  /// 'tired'). Couleur résolue via MoodColors.byKey à l'affichage.
  TextColumn get codeEmotion =>
      text().named('code_emotion').nullable()();

  /// Jeton d'accent CHROME pour les cartes rappel/conseil.
  ///
  /// Valeurs : 'primary' | 'lime' | 'or'. Ignoré pour 'emotion' (couleur
  /// dérivée de MoodColors). JAMAIS un hex (DEC-CO-07).
  TextColumn get accentChrome =>
      text().named('accent_chrome').withDefault(const Constant('primary'))();

  /// Ordre stable dans le corpus (rotation déterministe). Défaut = id.
  IntColumn get ordre =>
      integer().withDefault(const Constant(0))();
}

/// Agrégat journalier du temps d'écran — historique multi-jours (DEC-TE-04
/// révisé, Q-TE-5).
///
/// **1 ligne par jour, 100 % LOCALE, jamais transmise** (zéro-collecte = pas de
/// collecte externe). Seul l'**agrégat** est persisté pour permettre une
/// tendance ; le détail par app du jour courant reste calculé à la volée et
/// **n'est jamais** stocké ici.
@DataClassName('UsageEcranJournalier')
class UsagesEcranJournaliers extends Table {
  @override
  String get tableName => 'usages_ecran_journaliers';

  /// Identifiant auto-incrémenté.
  IntColumn get id => integer().autoIncrement()();

  /// Jour normalisé (minuit local) — clé d'unicité quotidienne.
  ///
  /// Stocké comme DateTime à 00:00:00 local. Index UNIQUE via [uniqueKeys]
  /// pour garantir un agrégat max par jour (UPSERT).
  DateTimeColumn get jour => dateTime().named('jour')();

  /// Total agrégé du jour, en **secondes** (somme des usages des apps).
  IntColumn get totalSecondes => integer().named('total_secondes')();

  /// Horodatage local de la dernière mise à jour de l'agrégat.
  DateTimeColumn get majLe => dateTime().named('maj_le')();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {jour},
  ];
}

/// Base de données locale unique de l'application (SQLite via Drift).
///
/// Persistance 100 % locale, zéro réseau. Le journal d'humeur vit
/// **uniquement** ici (DEC-001/002) ; l'état A/B est dérivé via `watch()`.
@DriftDatabase(
  tables: [EntreesHumeur, Conseils, UsagesEcranJournaliers, SeancesBienEtre],
)
class AppDatabase extends _$AppDatabase {
  /// Ouvre la base de production (fichier dans le dossier documents).
  AppDatabase() : super(_openConnection());

  /// Construit une base à partir d'un executor donné (tests : mémoire).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  /// Référence Unix epoch pour la rotation déterministe des conseils.
  static final DateTime _epoch = DateTime(1970);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedCorpus();
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
      if (from < 3) {
        // Crée la table d'historique du temps d'écran seulement si absente
        // (idempotence : sur une base semi-migrée, `createTable` lèverait
        // "table already exists"). On vérifie via `sqlite_master`.
        final tables = await customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name='usages_ecran_journaliers'",
        ).get();
        if (tables.isEmpty) {
          await m.createTable(usagesEcranJournaliers);
        }
        // Index unique sur `jour` (idempotent).
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_usages_ecran_journaliers_jour '
          'ON usages_ecran_journaliers(jour)',
        );
      }
      if (from < 4) {
        // Schéma v4 : ajoute 4 colonnes à la table `conseils` (DEC-CO-02).
        // Idempotent : vérifie PRAGMA table_info avant chaque addColumn.
        final colonnes = await customSelect(
          "PRAGMA table_info('conseils')",
        ).get();
        final noms = colonnes.map((r) => r.read<String>('name')).toSet();

        if (!noms.contains('type_carte')) {
          await m.addColumn(conseils, conseils.typeCarte);
        }
        if (!noms.contains('code_emotion')) {
          await m.addColumn(conseils, conseils.codeEmotion);
        }
        if (!noms.contains('accent_chrome')) {
          await m.addColumn(conseils, conseils.accentChrome);
        }
        if (!noms.contains('ordre')) {
          await m.addColumn(conseils, conseils.ordre);
        }

        // Re-métadonnées des tipDay01..07 existants : tous deviennent
        // des cartes 'rappel' avec accents cycliques (DEC-CO-11 / Q-CO-7).
        const tipAccents = [
          'primary',
          'lime',
          'or',
          'primary',
          'lime',
          'or',
          'primary',
        ];
        for (var i = 1; i <= 7; i++) {
          final accent = tipAccents[i - 1];
          await customStatement(
            "UPDATE conseils SET type_carte = 'rappel', "
            "accent_chrome = '$accent', ordre = $i "
            "WHERE cle_conseil = 'tipDay0$i'",
          );
        }

        // Ajoute les nouvelles cartes par INSERT … WHERE NOT EXISTS
        // (idempotence par cle_conseil — DEC-CO-02 / Q-CO-6).
        const nouvelles = [
          // rappels supplémentaires
          (
            'conseilRappelPresent',
            'rappel',
            null,
            'primary',
            8,
          ),
          ('conseilRappelLikes', 'rappel', null, 'or', 9),
          // conseils pratiques
          (
            'conseilPratiqueInteractions',
            'conseil',
            null,
            'lime',
            10,
          ),
          ('conseilPratiqueEspace', 'conseil', null, 'primary', 11),
          // cartes émotion (les 7 canoniques)
          ('conseilEmotionAngry', 'emotion', 'angry', 'primary', 12),
          ('conseilEmotionSad', 'emotion', 'sad', 'primary', 13),
          ('conseilEmotionNervous', 'emotion', 'nervous', 'primary', 14),
          ('conseilEmotionTired', 'emotion', 'tired', 'primary', 15),
          ('conseilEmotionHappy', 'emotion', 'happy', 'primary', 16),
          ('conseilEmotionCalm', 'emotion', 'calm', 'primary', 17),
          ('conseilEmotionDynamic', 'emotion', 'dynamic', 'primary', 18),
        ];

        for (final (cle, type, code, accent, ordre) in nouvelles) {
          final codeVal =
              code != null ? "'$code'" : 'NULL';
          await customStatement(
            'INSERT INTO conseils '
            '(cle_conseil, type_carte, code_emotion, accent_chrome, ordre) '
            "SELECT '$cle', '$type', $codeVal, '$accent', $ordre "
            'WHERE NOT EXISTS '
            "(SELECT 1 FROM conseils WHERE cle_conseil = '$cle')",
          );
        }
      }
      if (from < 5) {
        // Schéma v5 : crée la table des séances bien-être (wellbeing_stats).
        // Idempotent : vérifie sqlite_master avant createTable.
        final tables = await customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name='wellbeing_stats'",
        ).get();
        if (tables.isEmpty) {
          await m.createTable(seancesBienEtre);
        }
      }
    },
    beforeOpen: (details) async {
      // Seed idempotent par clé (ré-ouverture ou première installation).
      await _seedCorpus();
    },
  );

  /// Seed du corpus complet, idempotent PAR CLÉ (DEC-CO-02 / Q-CO-6).
  ///
  /// N'insère que les entrées dont `cle_conseil` est absente. Permet de
  /// compléter une base v3 (7 tipDay seedés) avec les nouvelles cartes émotion
  /// sans dupliquer les existantes.
  Future<void> _seedCorpus() async {
    const corpus = [
      // ── tipDay01..07 (rappels — DEC-CO-11 / Q-CO-7) ───────────────────
      (
        'tipDay01',
        'rappel',
        null,
        'primary',
        1,
      ),
      ('tipDay02', 'rappel', null, 'lime', 2),
      ('tipDay03', 'rappel', null, 'or', 3),
      ('tipDay04', 'rappel', null, 'primary', 4),
      ('tipDay05', 'rappel', null, 'lime', 5),
      ('tipDay06', 'rappel', null, 'or', 6),
      ('tipDay07', 'rappel', null, 'primary', 7),
      // ── Rappels supplémentaires ────────────────────────────────────────
      ('conseilRappelPresent', 'rappel', null, 'primary', 8),
      ('conseilRappelLikes', 'rappel', null, 'or', 9),
      // ── Conseils pratiques ─────────────────────────────────────────────
      ('conseilPratiqueInteractions', 'conseil', null, 'lime', 10),
      ('conseilPratiqueEspace', 'conseil', null, 'primary', 11),
      // ── Cartes émotion (7 canoniques) ─────────────────────────────────
      ('conseilEmotionAngry', 'emotion', 'angry', 'primary', 12),
      ('conseilEmotionSad', 'emotion', 'sad', 'primary', 13),
      ('conseilEmotionNervous', 'emotion', 'nervous', 'primary', 14),
      ('conseilEmotionTired', 'emotion', 'tired', 'primary', 15),
      ('conseilEmotionHappy', 'emotion', 'happy', 'primary', 16),
      ('conseilEmotionCalm', 'emotion', 'calm', 'primary', 17),
      ('conseilEmotionDynamic', 'emotion', 'dynamic', 'primary', 18),
    ];

    // Clés déjà présentes (évite INSERT en double).
    final existantes =
        await (select(conseils)..addColumns([conseils.cleConseil])).get();
    final clesPresentes = existantes.map((r) => r.cleConseil).toSet();

    for (final (cle, type, code, accent, ordre) in corpus) {
      if (clesPresentes.contains(cle)) continue;
      await into(conseils).insert(
        ConseilsCompanion.insert(
          cleConseil: cle,
          typeCarte: Value(type),
          codeEmotion: Value(code),
          accentChrome: Value(accent),
          ordre: Value(ordre),
        ),
      );
    }
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

  /// Renvoie `true` si une humeur a déjà été notée pour [jour]
  /// (défaut : aujourd'hui).
  ///
  /// Lecture ponctuelle (non réactive). Bornes `[minuit, minuit+1j)` identiques
  /// à [observerDerniereHumeurDuJour]. Borne haute **exclue**
  /// (`isSmallerThanValue`), sans post-filtrage, LIMIT 1.
  /// Aucun bump de schéma (DEC-R-02, DEC-001/002).
  Future<bool> humeurDuJourEstNotee({DateTime? jour}) async {
    final ref = jour ?? DateTime.now();
    final start = DateTime(ref.year, ref.month, ref.day);
    final end = start.add(const Duration(days: 1));
    final count = await (select(entreesHumeur)
          ..where(
            (t) =>
                t.creeLe.isBiggerOrEqualValue(start) &
                t.creeLe.isSmallerThanValue(end),
          )
          ..limit(1))
        .get();
    return count.isNotEmpty;
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

  /// Cartes **génériques** (type_carte != 'emotion'), ordonnées par `ordre`
  /// puis `id` — identique à la portion générique de `composerDeck`.
  ///
  /// Helper mutualisé : garantit que [conseilDuJour] et `composerDeck`
  /// tournent sur le même ensemble dans le même ordre (DEC-CO-11).
  Future<List<Conseil>> cartesGeneriquesOrdonnees() async {
    return (select(conseils)
          ..where((t) => t.typeCarte.isNotIn(['emotion']))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ordre),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  /// Conseil **déterministe** du jour [jour].
  ///
  /// Tourne UNIQUEMENT sur les cartes **génériques**
  /// (`type_carte` != `'emotion'`) dans le même ordre (`ordre`/`id`) et
  /// le même modulo que la rotation générique de `composerDeck` (DEC-CO-11).
  ///
  /// Garantie : la clé renvoyée est toujours affichable par
  /// `_resoudreConseil` de l'Accueil — jamais une clé `conseilEmotion*`.
  Future<Conseil> conseilDuJour(DateTime jour) async {
    final generiques = await cartesGeneriquesOrdonnees();
    if (generiques.isEmpty) {
      throw StateError('Aucun conseil générique seedé dans la base.');
    }
    final jourNormalise = DateTime(jour.year, jour.month, jour.day);
    final joursDepuisEpoch = jourNormalise.difference(_epoch).inDays;
    final index = joursDepuisEpoch % generiques.length;
    return generiques[index];
  }

  /// Corpus complet de cartes, ordonné par `ordre` puis `id`.
  ///
  /// Utilisé par ConseilsBloc pour composer le deck (DEC-CO-01).
  /// Lecture ponctuelle (pas de watch) — deck figé à l'ouverture (DEC-CO-06).
  Future<List<Conseil>> lireCorpusConseils() async {
    return (select(conseils)
          ..orderBy([
            (t) => OrderingTerm.asc(t.ordre),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  // ─── Soutien ──────────────────────────────────────────────────────────────

  /// Seuil de déclenchement du soutien : 7 saisies négatives consécutives.
  ///
  /// Source unique du seuil (DEC-SOP-005) ; partagé avec
  /// EvaluateurSoutien.seuil qui y fait référence.
  static const int seuilSoutien = 7;

  /// Compte les saisies négatives consécutives EN PARTANT DE LA PLUS RÉCENTE.
  ///
  /// Lit le journal trié par date décroissante et additionne tant que la
  /// valence est < 0 ; s'arrête à la première saisie positive/neutre.
  /// Les jours sans
  /// saisie n'apparaissent pas dans le journal → naturellement ignorés.
  /// Dérivé de Drift (DEC-001), jamais dupliqué dans HydratedBloc.
  Future<int> compterSaisiesNegativesConsecutives() async {
    final entrees = await (select(
      entreesHumeur,
    )..orderBy([(t) => OrderingTerm.desc(t.creeLe)])).get();

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
  /// N'inclut PAS l'anti-relance (portée par SoutienBloc).
  Future<bool> aDeclencherSoutien() async {
    return await compterSaisiesNegativesConsecutives() >= seuilSoutien;
  }

  // ─── Temps d'écran (historique journalier, DEC-TE-04 révisé) ──────────────

  /// UPSERT de l'agrégat de temps d'écran du jour courant.
  ///
  /// 1 ligne par jour (index unique `jour`). Persiste **uniquement le total**
  /// (en secondes), jamais le détail par app. 100 % local, jamais transmis.
  Future<void> enregistrerUsageDuJour(Duration total, {DateTime? maintenant}) {
    final now = maintenant ?? DateTime.now();
    final jourNormalise = DateTime(now.year, now.month, now.day);
    final companion = UsagesEcranJournaliersCompanion.insert(
      jour: jourNormalise,
      totalSecondes: total.inSeconds,
      majLe: now,
    );
    return into(usagesEcranJournaliers).insert(
      companion,
      onConflict: DoUpdate(
        (_) => companion,
        target: [usagesEcranJournaliers.jour],
      ),
    );
  }

  /// Historique du temps d'écran sur les [nbJours] derniers jours, réactif.
  ///
  /// Trié par `jour` croissant. Lecture 100 % locale.
  Stream<List<UsageEcranJournalier>> observerHistoriqueUsage({
    int nbJours = 7,
  }) {
    final now = DateTime.now();
    final aujourdhui = DateTime(now.year, now.month, now.day);
    final debut = aujourdhui.subtract(Duration(days: nbJours - 1));
    return (select(usagesEcranJournaliers)
          ..where((t) => t.jour.isBiggerOrEqualValue(debut))
          ..orderBy([(t) => OrderingTerm.asc(t.jour)]))
        .watch();
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

  // ─── Séances bien-être ────────────────────────────────────────────────────

  /// Incrémente de 1 le compteur de séances pour l'exercice [exerciceId].
  ///
  /// UPSERT sur la clé primaire `exercice_id` : crée la ligne si absente,
  /// sinon met à jour le compteur et l'horodatage.
  Future<void> enregistrerSeanceBienEtre(String exerciceId) async {
    final existante =
        await (select(seancesBienEtre)
              ..where((t) => t.exerciceId.equals(exerciceId)))
            .getSingleOrNull();
    final prochain = (existante?.nombreSeances ?? 0) + 1;
    await into(seancesBienEtre).insertOnConflictUpdate(
      SeancesBienEtreCompanion.insert(
        exerciceId: exerciceId,
        nombreSeances: Value(prochain),
        derniereSeanceLe: Value(DateTime.now()),
      ),
    );
  }

  /// Flux réactif du nombre de séances terminées pour [exerciceId].
  Stream<int> observerNombreSeances(String exerciceId) {
    return (select(seancesBienEtre)
          ..where((t) => t.exerciceId.equals(exerciceId)))
        .watchSingleOrNull()
        .map((row) => row?.nombreSeances ?? 0);
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
