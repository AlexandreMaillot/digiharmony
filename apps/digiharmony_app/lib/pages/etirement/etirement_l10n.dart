import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/l10n/l10n.dart';

/// Resolution segment -> label / instruction ARB (par id).
extension SegmentEtirementL10n on SegmentEtirement {
  /// Libelle traduit du segment.
  String label(AppLocalizations l) => switch (id) {
    IdSegmentEtirement.anchor => l.stretchSegmentAnchorLabel,
    IdSegmentEtirement.neckShoulders => l.stretchSegmentNeckShouldersLabel,
    IdSegmentEtirement.hands => l.stretchSegmentHandsLabel,
    IdSegmentEtirement.restEyes => l.stretchSegmentRestEyesLabel,
  };

  /// Instruction traduite du segment.
  String instruction(AppLocalizations l) => switch (id) {
    IdSegmentEtirement.anchor => l.stretchSegmentAnchorInstruction,
    IdSegmentEtirement.neckShoulders =>
      l.stretchSegmentNeckShouldersInstruction,
    IdSegmentEtirement.hands => l.stretchSegmentHandsInstruction,
    IdSegmentEtirement.restEyes => l.stretchSegmentRestEyesInstruction,
  };
}

/// Resolution d'une cle de label de segment vers son texte (pour la liste).
String etirementLabelPourCle(AppLocalizations l, String key) => switch (key) {
  'stretchSegmentAnchorLabel' => l.stretchSegmentAnchorLabel,
  'stretchSegmentNeckShouldersLabel' => l.stretchSegmentNeckShouldersLabel,
  'stretchSegmentHandsLabel' => l.stretchSegmentHandsLabel,
  'stretchSegmentRestEyesLabel' => l.stretchSegmentRestEyesLabel,
  _ => key,
};

/// Formate une duree en m:ss.
String formatTempsEtirement(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
