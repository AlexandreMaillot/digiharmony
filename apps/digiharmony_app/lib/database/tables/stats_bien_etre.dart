import 'package:drift/drift.dart';

/// Agregat local par type d'exercice bien-etre (extensible aux bulles).
///
/// 100 % sur l'appareil, zero collecte. Cle = `exerciseId`.
/// Le nom SQL `wellbeing_stats` est preserve pour la compatibilite schema.
class StatsBienEtre extends Table {
  @override
  String get tableName => 'wellbeing_stats';

  /// Identifiant d'exercice (ex. 'breathing', 'senses', 'stretch', 'detox').
  TextColumn get exerciseId => text()();

  /// Nombre de seances terminees.
  IntColumn get completedCount => integer().withDefault(const Constant(0))();

  /// Date de la derniere seance terminee.
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {exerciseId};
}
