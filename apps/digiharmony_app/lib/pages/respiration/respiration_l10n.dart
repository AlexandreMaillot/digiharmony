import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/l10n/l10n.dart';

/// Resolution phase -> libelle ARB.
extension PhaseRespirationL10n on PhaseRespiration {
  /// Libelle traduit de la phase.
  String label(AppLocalizations l) => switch (this) {
    PhaseRespiration.inhale => l.breathingPhaseInhale,
    PhaseRespiration.hold => l.breathingPhaseHold,
    PhaseRespiration.exhale => l.breathingPhaseExhale,
  };
}
