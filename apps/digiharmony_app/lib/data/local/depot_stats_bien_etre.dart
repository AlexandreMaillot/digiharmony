import 'package:digiharmony_app/data/local/app_database.dart';

/// Contrat du dépôt des séances bien-être terminées.
///
/// Interface injectable pour la testabilité (mock via mocktail).
abstract class DepotStatsBienEtre {
  /// Incrémente de 1 le compteur pour l'exercice [exerciceId].
  Future<void> enregistrerSeance(String exerciceId);

  /// Flux réactif du nombre de séances terminées pour [exerciceId].
  Stream<int> observerNombreSeances(String exerciceId);
}

/// Implémentation Drift de [DepotStatsBienEtre].
///
/// Délègue à AppDatabase ; ne duplique pas la logique SQL.
class DepotDriftStatsBienEtre implements DepotStatsBienEtre {
  /// Crée le dépôt avec la base unique de l'application.
  const DepotDriftStatsBienEtre(this._db);

  final AppDatabase _db;

  @override
  Future<void> enregistrerSeance(String exerciceId) =>
      _db.enregistrerSeanceBienEtre(exerciceId);

  @override
  Stream<int> observerNombreSeances(String exerciceId) =>
      _db.observerNombreSeances(exerciceId);
}
