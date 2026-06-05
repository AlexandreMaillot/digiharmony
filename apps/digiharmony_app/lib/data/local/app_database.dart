import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Journal d'humeur — table en **lecture seule** pour l'Accueil (état A/B).
///
/// L'écriture appartient à l'écran « Noter mon humeur » (hors périmètre).
/// Schéma minimal provisoire (DEC-FND-06), figé avec l'US « Noter mon humeur ».
@DataClassName('EntreeHumeur')
class EntreesHumeur extends Table {
  @override
  String get tableName => 'entrees_humeur';

  /// Identifiant auto-incrémenté.
  IntColumn get id => integer().autoIncrement()();

  /// Code stable de l'émotion (aligné `MoodColors.byKey`).
  TextColumn get codeEmotion => text().named('code_emotion')();

  /// Valence : >= 0 positive/neutre, < 0 négative.
  ///
  /// Sert au futur compteur « 7 émotions négatives consécutives », dérivé de
  /// Drift (DEC-001), jamais dupliqué dans HydratedBloc.
  IntColumn get valence => integer()();

  /// Horodatage local de création.
  DateTimeColumn get creeLe => dateTime().named('cree_le')();
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
  int get schemaVersion => 1;

  /// Référence Unix epoch pour la rotation déterministe des conseils.
  static final DateTime _epoch = DateTime(1970);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedConseils();
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

  /// Dernière entrée d'humeur du jour courant, réactif.
  ///
  /// Émet `null` si aucune entrée aujourd'hui. Bornes `[minuit, minuit+1j)`,
  /// tri `creeLe DESC LIMIT 1`.
  Stream<EntreeHumeur?> observerDerniereHumeurDuJour() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final query = (select(entreesHumeur)
          ..where((t) => t.creeLe.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.creeLe)])
          ..limit(1))
        .watchSingleOrNull();
    // `isBetweenValues` est inclusif sur les deux bornes ; on exclut minuit+1j.
    return query.map((row) {
      if (row == null) return null;
      if (!row.creeLe.isBefore(end)) return null;
      return row;
    });
  }

  /// Conseil **déterministe** du jour [jour].
  ///
  /// `index = joursDepuisEpoch % nbConseils`, stable toute la journée,
  /// sans aléatoire ni stockage d'état.
  Future<Conseil> conseilDuJour(DateTime jour) async {
    final all = await (select(conseils)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    if (all.isEmpty) {
      throw StateError('Aucun conseil seedé dans la base.');
    }
    final jourNormalise = DateTime(jour.year, jour.month, jour.day);
    final joursDepuisEpoch = jourNormalise.difference(_epoch).inDays;
    final index = joursDepuisEpoch % all.length;
    return all[index];
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'digiharmony.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
