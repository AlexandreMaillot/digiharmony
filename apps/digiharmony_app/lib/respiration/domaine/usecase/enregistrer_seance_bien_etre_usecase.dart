import 'package:digiharmony_app/database/depot_stats_bien_etre.dart';

/// Enregistre une séance de respiration terminée dans Drift.
///
/// L'idempotence (garde-fou statsPersisted) est gérée au niveau du Bloc ;
/// ce UseCase s'occupe uniquement de l'écriture.
class EnregistrerSeanceBienEtreUseCase {
  /// {@macro enregistrer_seance_bien_etre_usecase}
  const EnregistrerSeanceBienEtreUseCase({required DepotStatsBienEtre depot})
    : _depot = depot;

  final DepotStatsBienEtre _depot;

  /// Appelle [DepotStatsBienEtre.recordCompletedSession] pour l'exercice
  /// [exerciceId] (ex. `'breathing'`).
  Future<void> appeler(String exerciceId) =>
      _depot.recordCompletedSession(exerciceId);
}
