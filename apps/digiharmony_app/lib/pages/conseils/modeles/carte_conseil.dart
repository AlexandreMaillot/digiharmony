import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte composée du deck Conseils, prête à afficher.
///
/// Le texte est résolu à l'affichage depuis les ARB via les clés i18n.
/// Sealed class = pattern exhaustif au switch (DEC-CO-01).
sealed class CarteConseil {
  const CarteConseil({required this.cleContenu});

  /// Clé de base i18n (ex. 'conseilRappelPresent', 'conseilEmotionAngry').
  final String cleContenu;
}

/// Carte de type « rappel » : citation 2 lignes + sous-texte + tag.
///
/// Clés ARB : `<cleContenu>Citation1`, `<cleContenu>Citation2`,
/// `<cleContenu>SousTexte`, `<cleContenu>Tag`.
class CarteRappel extends CarteConseil {
  /// Crée une carte rappel.
  const CarteRappel({
    required super.cleContenu,
    required this.accentChrome,
  });

  /// Jeton d'accent chrome : 'primary' | 'lime' | 'or' (DEC-CO-07).
  final String accentChrome;
}

/// Carte de type « conseil pratique » : headline + Do's/Don'ts + tag.
///
/// Clés ARB : `<cleContenu>Headline`, `<cleContenu>Do1..3`,
/// `<cleContenu>Dont1..2`, `<cleContenu>Tag`.
class CarteConseilPratique extends CarteConseil {
  /// Crée une carte conseil pratique.
  const CarteConseilPratique({
    required super.cleContenu,
    required this.accentChrome,
  });

  /// Jeton d'accent chrome : 'primary' | 'lime' | 'or' (DEC-CO-07).
  final String accentChrome;
}

/// Carte de type « émotion » : headline contextuel + Do's/Don'ts + CTA stub.
///
/// Headline = `conseilsEmotionHeadline({emotion})` (clé partagée).
/// Clés ARB : `<cleContenu>Do1..3`, `<cleContenu>Dont1..2`.
/// Couleur = `MoodColors.byKey[codeEmotion]` — JAMAIS un hex (DEC-CO-07).
class CarteEmotion extends CarteConseil {
  /// Crée une carte émotion.
  const CarteEmotion({
    required super.cleContenu,
    required this.codeEmotion,
  });

  /// Code de l'émotion canonique (ex. 'angry', 'sad', 'happy').
  final String codeEmotion;
}

/// Résout un jeton d'accent chrome en [Color] (DEC-CO-07).
///
/// Violet (`MoodColors.nervous`) interdit en chrome — jamais retourné ici.
Color resoudreAccentChrome(String accentChrome) {
  return switch (accentChrome) {
    'or' => AppColors.accentGold,
    'lime' => AppColors.signatureGradient[1],
    _ => AppColors.primary, // 'primary' + fallback
  };
}

/// Résout la [Color] d'une carte quel que soit son type.
///
/// - [CarteEmotion] → `MoodColors.byKey[code]` (jamais hex mockup).
/// - [CarteRappel] / [CarteConseilPratique] → palette chrome.
Color accentDeCarte(CarteConseil carte) {
  return switch (carte) {
    CarteEmotion(:final codeEmotion) =>
      MoodColors.byKey[codeEmotion] ?? AppColors.primary,
    CarteRappel(:final accentChrome) ||
    CarteConseilPratique(:final accentChrome) =>
      resoudreAccentChrome(accentChrome),
  };
}
