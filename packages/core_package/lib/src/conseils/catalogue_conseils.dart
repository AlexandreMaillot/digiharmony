import 'package:flutter/material.dart';

/// Identifiants stables des emotions negatives du carrousel de conseils.
///
/// Ordre = ordre d'affichage des cartes.
enum EmotionNegative { anger, sadness, fear, stress, loneliness }

/// Exercice propose par une carte de conseil (extensible).
///
/// V1 : respiration uniquement.
enum ExerciceConseil { respiration }

/// Conseil associe a une emotion negative — donnee pure, immuable.
///
/// Suit le pattern `CategorieBulle` : aucune persistance, aucune collecte,
/// liste const en memoire. Le texte (titre / a-faire / a-eviter) est resolu
/// via l'ARB cote app par CLES i18n, jamais stocke en dur ici.
@immutable
class ConseilEmotion {
  /// {@macro conseil_emotion}
  const ConseilEmotion({
    required this.id,
    required this.color,
    required this.titleKey,
    required this.doKeys,
    required this.avoidKeys,
    required this.exercise,
  });

  /// Identifiant stable de l'emotion.
  final EmotionNegative id;

  /// Couleur d'accent de l'emotion.
  final Color color;

  /// Cle ARB du titre « Quand tu te sens... ».
  final String titleKey;

  /// 3 cles ARB « a faire ».
  final List<String> doKeys;

  /// 2 cles ARB « a eviter ».
  final List<String> avoidKeys;

  /// Exercice associe (defaut respiration).
  final ExerciceConseil exercise;
}

/// Catalogue STATIQUE des conseils — SOURCE DE VERITE UNIQUE.
///
/// Contenu de reference fixe, multilingue, sans etat (meme pattern que
/// `CategorieBulle.all`). N'est PAS duplique en Drift (eviterait la
/// duplication de la verite — DEC-001/DEC-002).
abstract final class CatalogueConseils {
  /// Les 5 cartes, une par emotion, dans l'ordre d'affichage.
  static const List<ConseilEmotion> all = <ConseilEmotion>[
    ConseilEmotion(
      id: EmotionNegative.anger,
      color: Color(0xFFE5392B), // rouge colere (du mockup)
      titleKey: 'adviceCardTitleAnger',
      doKeys: <String>['adviceDoAnger1', 'adviceDoAnger2', 'adviceDoAnger3'],
      avoidKeys: <String>['adviceAvoidAnger1', 'adviceAvoidAnger2'],
      exercise: ExerciceConseil.respiration,
    ),
    ConseilEmotion(
      id: EmotionNegative.sadness,
      color: Color(0xFF3FB8E6), // bleu = primary
      titleKey: 'adviceCardTitleSadness',
      doKeys: <String>[
        'adviceDoSadness1',
        'adviceDoSadness2',
        'adviceDoSadness3',
      ],
      avoidKeys: <String>['adviceAvoidSadness1', 'adviceAvoidSadness2'],
      exercise: ExerciceConseil.respiration,
    ),
    ConseilEmotion(
      id: EmotionNegative.fear,
      color: Color(0xFF9B7BE8), // violet (teinte « senses »)
      titleKey: 'adviceCardTitleFear',
      doKeys: <String>['adviceDoFear1', 'adviceDoFear2', 'adviceDoFear3'],
      avoidKeys: <String>['adviceAvoidFear1', 'adviceAvoidFear2'],
      exercise: ExerciceConseil.respiration,
    ),
    ConseilEmotion(
      id: EmotionNegative.stress,
      color: Color(0xFFF0C84A), // jaune = sensesAccent
      titleKey: 'adviceCardTitleStress',
      doKeys: <String>[
        'adviceDoStress1',
        'adviceDoStress2',
        'adviceDoStress3',
      ],
      avoidKeys: <String>['adviceAvoidStress1', 'adviceAvoidStress2'],
      exercise: ExerciceConseil.respiration,
    ),
    ConseilEmotion(
      id: EmotionNegative.loneliness,
      color: Color(0xFFA8D24E), // vert = success
      titleKey: 'adviceCardTitleLoneliness',
      doKeys: <String>[
        'adviceDoLoneliness1',
        'adviceDoLoneliness2',
        'adviceDoLoneliness3',
      ],
      avoidKeys: <String>['adviceAvoidLoneliness1', 'adviceAvoidLoneliness2'],
      exercise: ExerciceConseil.respiration,
    ),
  ];

  /// Recherche par identifiant (mode `idEmotionInitiale`).
  ///
  /// `rawId` = `EmotionNegative.name`. Retourne `null` si introuvable.
  static ConseilEmotion? parId(String? rawId) {
    if (rawId == null) return null;
    for (final conseil in all) {
      if (conseil.id.name == rawId) return conseil;
    }
    return null;
  }

  /// Index d'une emotion dans [all] (sync PageController). `-1` si introuvable.
  static int indexDe(String? rawId) {
    if (rawId == null) return -1;
    for (var i = 0; i < all.length; i++) {
      if (all[i].id.name == rawId) return i;
    }
    return -1;
  }
}
