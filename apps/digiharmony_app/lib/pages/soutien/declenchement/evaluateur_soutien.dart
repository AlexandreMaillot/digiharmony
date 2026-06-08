import 'package:digiharmony_app/data/local/app_database.dart';

/// Décision pure de déclenchement de l'écran de soutien.
///
/// Sans I/O, sans Flutter, sans Drift : testable isolément.
/// Le seuil est aligné sur [AppDatabase.seuilSoutien]
/// (source unique, DEC-SOP-005).
abstract final class EvaluateurSoutien {
  /// Nombre de saisies négatives consécutives déclenchant le soutien.
  ///
  /// Pointe sur [AppDatabase.seuilSoutien] — source unique (DEC-SOP-005).
  static const int seuil = AppDatabase.seuilSoutien;

  /// Retourne `true` si l'écran de soutien doit être affiché.
  ///
  /// Conditions : [compteurNegativesConsecutives] >= [seuil] ET
  /// [dejaMontrePourEpisodeEnCours] == false
  /// (une fois par épisode, DEC-SO-004).
  ///
  /// Pur : aucun I/O, aucune dépendance Flutter.
  static bool doitDeclencher({
    required int compteurNegativesConsecutives,
    required bool dejaMontrePourEpisodeEnCours,
  }) {
    if (compteurNegativesConsecutives < seuil) return false;
    return !dejaMontrePourEpisodeEnCours;
  }
}
