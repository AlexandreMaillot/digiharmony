import 'package:digiharmony_app/l10n/l10n.dart';

/// Resout une CLE i18n de conseil (String stockee dans le catalogue
/// `core_package`) vers sa valeur traduite.
///
/// Le catalogue ne porte que des cles (jamais de texte) ; gen-l10n genere des
/// getters typés, pas de lookup par String. On fait donc le pont ici par un
/// switch exhaustif sur les cles du catalogue.
extension ConseilsL10n on AppLocalizations {
  /// Valeur traduite pour une cle de conseil. Repli sur la cle brute si
  /// inconnue (ne devrait jamais arriver — catalogue fige).
  String conseilTexte(String key) {
    switch (key) {
      // Titres
      case 'adviceCardTitleAnger':
        return adviceCardTitleAnger;
      case 'adviceCardTitleSadness':
        return adviceCardTitleSadness;
      case 'adviceCardTitleFear':
        return adviceCardTitleFear;
      case 'adviceCardTitleStress':
        return adviceCardTitleStress;
      case 'adviceCardTitleLoneliness':
        return adviceCardTitleLoneliness;
      // A faire
      case 'adviceDoAnger1':
        return adviceDoAnger1;
      case 'adviceDoAnger2':
        return adviceDoAnger2;
      case 'adviceDoAnger3':
        return adviceDoAnger3;
      case 'adviceDoSadness1':
        return adviceDoSadness1;
      case 'adviceDoSadness2':
        return adviceDoSadness2;
      case 'adviceDoSadness3':
        return adviceDoSadness3;
      case 'adviceDoFear1':
        return adviceDoFear1;
      case 'adviceDoFear2':
        return adviceDoFear2;
      case 'adviceDoFear3':
        return adviceDoFear3;
      case 'adviceDoStress1':
        return adviceDoStress1;
      case 'adviceDoStress2':
        return adviceDoStress2;
      case 'adviceDoStress3':
        return adviceDoStress3;
      case 'adviceDoLoneliness1':
        return adviceDoLoneliness1;
      case 'adviceDoLoneliness2':
        return adviceDoLoneliness2;
      case 'adviceDoLoneliness3':
        return adviceDoLoneliness3;
      // A eviter
      case 'adviceAvoidAnger1':
        return adviceAvoidAnger1;
      case 'adviceAvoidAnger2':
        return adviceAvoidAnger2;
      case 'adviceAvoidSadness1':
        return adviceAvoidSadness1;
      case 'adviceAvoidSadness2':
        return adviceAvoidSadness2;
      case 'adviceAvoidFear1':
        return adviceAvoidFear1;
      case 'adviceAvoidFear2':
        return adviceAvoidFear2;
      case 'adviceAvoidStress1':
        return adviceAvoidStress1;
      case 'adviceAvoidStress2':
        return adviceAvoidStress2;
      case 'adviceAvoidLoneliness1':
        return adviceAvoidLoneliness1;
      case 'adviceAvoidLoneliness2':
        return adviceAvoidLoneliness2;
    }
    return key;
  }
}
