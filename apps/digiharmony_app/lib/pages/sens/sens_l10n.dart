import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Resolution sens -> label / instruction / icone.
extension SensAncrageL10n on SensAncrage {
  /// Libelle traduit du sens.
  String label(AppLocalizations l) => switch (this) {
    SensAncrage.see => l.sensesStepSeeLabel,
    SensAncrage.touch => l.sensesStepTouchLabel,
    SensAncrage.hear => l.sensesStepHearLabel,
    SensAncrage.smell => l.sensesStepSmellLabel,
    SensAncrage.taste => l.sensesStepTasteLabel,
  };

  /// Instruction traduite du sens.
  String instruction(AppLocalizations l) => switch (this) {
    SensAncrage.see => l.sensesStepSeeInstruction,
    SensAncrage.touch => l.sensesStepTouchInstruction,
    SensAncrage.hear => l.sensesStepHearInstruction,
    SensAncrage.smell => l.sensesStepSmellInstruction,
    SensAncrage.taste => l.sensesStepTasteInstruction,
  };

  /// Icone Material du sens.
  IconData get icon => switch (this) {
    SensAncrage.see => Icons.visibility_outlined,
    SensAncrage.touch => Icons.back_hand_outlined,
    SensAncrage.hear => Icons.hearing_outlined,
    SensAncrage.smell => Icons.air,
    SensAncrage.taste => Icons.restaurant_outlined,
  };
}
