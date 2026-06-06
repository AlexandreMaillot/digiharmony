import 'package:digiharmony_app/l10n/l10n.dart';

/// Résout le libellé localisé d'une émotion depuis son [codeEmotion].
///
/// Utilise les clés `mood*` de l'ARB. Repli sur [codeEmotion] si inconnu.
/// Usage unique — ne pas dupliquer cette logique dans les widgets journal.
String libelleEmotion(AppLocalizations l10n, String codeEmotion) {
  switch (codeEmotion) {
    case 'happy':
      return l10n.moodHappy;
    case 'calm':
      return l10n.moodCalm;
    case 'dynamic':
      return l10n.moodDynamic;
    case 'sad':
      return l10n.moodSad;
    case 'angry':
      return l10n.moodAngry;
    case 'nervous':
      return l10n.moodNervous;
    case 'tired':
      return l10n.moodTired;
    default:
      return codeEmotion;
  }
}
