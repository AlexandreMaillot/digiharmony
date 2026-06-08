import 'package:digiharmony_app/database/base_de_donnees.dart';
import 'package:drift/drift.dart';

/// Acces a l'agregat local des seances bien-etre terminees.
///
/// Interface injectable pour la testabilite (mock via mocktail).
abstract class DepotStatsBienEtre {
  /// Incremente de 1 le compteur de l'exercice et met a jour la date.
  Future<void> recordCompletedSession(String exerciseId);

  /// Flux reactif du nombre de seances terminees (futur ecran stats).
  Stream<int> watchCompletedCount(String exerciseId);
}

/// Implementation Drift de [DepotStatsBienEtre].
class DepotDriftStatsBienEtre implements DepotStatsBienEtre {
  /// {@macro depot_drift_stats_bien_etre}
  const DepotDriftStatsBienEtre(this._db);

  final BaseDeDonnees _db;

  @override
  Future<void> recordCompletedSession(String exerciseId) async {
    final existing =
        await (_db.select(_db.statsBienEtre)
              ..where((t) => t.exerciseId.equals(exerciseId)))
            .getSingleOrNull();
    final nextCount = (existing?.completedCount ?? 0) + 1;
    await _db
        .into(_db.statsBienEtre)
        .insertOnConflictUpdate(
          StatsBienEtreCompanion.insert(
            exerciseId: exerciseId,
            completedCount: Value(nextCount),
            lastCompletedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Stream<int> watchCompletedCount(String exerciseId) {
    final query = _db.select(_db.statsBienEtre)
      ..where((t) => t.exerciseId.equals(exerciseId));
    return query.watchSingleOrNull().map((row) => row?.completedCount ?? 0);
  }
}
