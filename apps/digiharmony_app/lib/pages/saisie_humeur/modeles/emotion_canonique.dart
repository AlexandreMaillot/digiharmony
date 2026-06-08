import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';

/// Représente une émotion canonique de l'application.
///
/// Les 7 émotions DEC-003 sont listées dans [emotionsCanoniques] (ordre
/// d'affichage fixé). Chaque instance porte la clé, l'emoji et la valence.
/// La couleur et le libellé sont résolus à l'affichage via `MoodColors.byKey`
/// et les clés i18n `mood*` — jamais stockés ici.
class EmotionCanonique {
  const EmotionCanonique({
    required this.cle,
    required this.emoji,
    required this.valence,
  });

  /// Code stable de l'émotion (ex. 'happy', 'sad'…).
  final String cle;

  /// Emoji représentant l'émotion (affiché dans les pastilles).
  final String emoji;

  /// Valence déterministe : >= 0 positive/neutre, < 0 négative (DEC-SH-002).
  final int valence;

  /// Délègue à [valencePour] pour cohérence avec la couche data.
  static int valencePourCode(String codeEmotion) => valencePour(codeEmotion);
}

/// Liste ordonnée des 7 émotions canoniques (source de vérité UI — DEC-003).
///
/// Ordre d'affichage fixé : positives/neutres d'abord, négatives ensuite.
const List<EmotionCanonique> emotionsCanoniques = [
  EmotionCanonique(cle: 'happy', emoji: '😊', valence: 1),
  EmotionCanonique(cle: 'calm', emoji: '😌', valence: 1),
  EmotionCanonique(cle: 'dynamic', emoji: '⚡', valence: 1),
  EmotionCanonique(cle: 'sad', emoji: '😢', valence: -1),
  EmotionCanonique(cle: 'angry', emoji: '😠', valence: -1),
  EmotionCanonique(cle: 'nervous', emoji: '😰', valence: -1),
  EmotionCanonique(cle: 'tired', emoji: '😴', valence: -1),
];

/// Libellé localisé d'une émotion canonique (clés `mood*`). Source unique.
///
/// Repli sur [code] si le code est inconnu (HC-6). Toute résolution
/// `code → libellé` de l'app doit passer par cette fonction (DRY).
String libelleEmotion(AppLocalizations l10n, String code) {
  switch (code) {
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
      return code;
  }
}

/// Retourne l'emoji pour un [codeEmotion], ou '' si inconnu.
String emojiPourCode(String codeEmotion) {
  return emotionsCanoniques
      .firstWhere(
        (e) => e.cle == codeEmotion,
        orElse: () => const EmotionCanonique(cle: '', emoji: '', valence: 0),
      )
      .emoji;
}
