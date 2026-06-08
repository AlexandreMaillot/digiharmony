import 'package:digiharmony_app/l10n/l10n.dart';

/// Formate une [duree] en libellé i18n bienveillant.
///
/// - `duree >= 1h` → `tempsEcranDureeHeuresMinutes` (« 3 h 12 min »).
/// - sinon → `tempsEcranDureeMinutes` (« 12 min »).
///
/// Les minutes sont le reste après extraction des heures. Le gabarit
/// (séparation h/min) vit dans l'ARB ; ce helper calcule h/min.
String formaterDuree(AppLocalizations l10n, Duration duree) {
  final totalMinutes = duree.inMinutes;
  final heures = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (heures > 0) {
    return l10n.tempsEcranDureeHeuresMinutes(heures, minutes);
  }
  return l10n.tempsEcranDureeMinutes(minutes);
}
