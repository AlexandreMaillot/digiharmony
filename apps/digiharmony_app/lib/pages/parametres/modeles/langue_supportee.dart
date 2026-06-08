/// Modèle de langue supportée par l'application.
///
/// Répertorie les 8 langues dans l'ordre de la maquette. Les endonymes
/// (noms natifs) sont des constantes Dart — ils ne sont PAS traduits
/// (DEC-PARAM-03).
class LangueSupportee {
  /// Crée une langue supportée.
  const LangueSupportee({
    required this.code,
    required this.endonyme,
    required this.drapeau,
  });

  /// Code BCP 47 (aligné sur supportedLocales).
  final String code;

  /// Nom natif de la langue — jamais traduit (DEC-PARAM-03).
  final String endonyme;

  /// Drapeau emoji de la langue.
  final String drapeau;
}

/// Liste des 8 langues supportées, dans l'ordre de la maquette.
///
/// Doit rester alignée sur `AppLocalizations.supportedLocales` (AC9).
/// Les endonymes sont des constantes — ils ne changent pas selon la locale.
const List<LangueSupportee> languesSupportees = <LangueSupportee>[
  LangueSupportee(code: 'en', endonyme: 'English', drapeau: '🇬🇧'),
  LangueSupportee(code: 'fr', endonyme: 'Français', drapeau: '🇫🇷'),
  LangueSupportee(code: 'el', endonyme: 'Ελληνικά', drapeau: '🇬🇷'),
  LangueSupportee(code: 'it', endonyme: 'Italiano', drapeau: '🇮🇹'),
  LangueSupportee(code: 'ro', endonyme: 'Română', drapeau: '🇷🇴'),
  LangueSupportee(code: 'tr', endonyme: 'Türkçe', drapeau: '🇹🇷'),
  LangueSupportee(code: 'es', endonyme: 'Español', drapeau: '🇪🇸'),
  LangueSupportee(code: 'mk', endonyme: 'Македонски', drapeau: '🇲🇰'),
];
