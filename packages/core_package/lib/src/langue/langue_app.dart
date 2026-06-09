import 'package:equatable/equatable.dart';

/// Une langue supportee par l'app. Donnee pure, immuable, sans I/O, sans
/// dependance Flutter (on stocke le `code` String, jamais un `Locale`).
///
/// L'autonyme (nom natif de la langue) n'est JAMAIS traduit : « Francais »
/// reste « Francais » quelle que soit la langue d'UI courante. Il ne va donc
/// pas dans les ARB — ce sont des constantes.
class LangueApp extends Equatable {
  /// {@macro langue_app}
  const LangueApp({
    required this.code,
    required this.flag,
    required this.autonym,
  });

  /// Code locale ISO : en, fr, el, it, ro, tr, es, mk.
  final String code;

  /// Drapeau emoji (texte), jamais un asset image.
  final String flag;

  /// Nom natif NON traduit (English, Francais, Ellinika, ...).
  final String autonym;

  @override
  List<Object?> get props => <Object?>[code, flag, autonym];
}

/// Les 8 langues du projet, dans l'ORDRE de la maquette.
///
/// Doit refleter `AppLocalizations.supportedLocales` (meme ensemble, meme
/// ordre). Toute divergence est un bug (cf. test d'invariant cote app).
const List<LangueApp> kLanguesSupportees = <LangueApp>[
  LangueApp(code: 'en', flag: '🇬🇧', autonym: 'English'),
  LangueApp(code: 'fr', flag: '🇫🇷', autonym: 'Français'),
  LangueApp(code: 'el', flag: '🇬🇷', autonym: 'Ελληνικά'),
  LangueApp(code: 'it', flag: '🇮🇹', autonym: 'Italiano'),
  LangueApp(code: 'ro', flag: '🇷🇴', autonym: 'Română'),
  LangueApp(code: 'tr', flag: '🇹🇷', autonym: 'Türkçe'),
  LangueApp(code: 'es', flag: '🇪🇸', autonym: 'Español'),
  LangueApp(code: 'mk', flag: '🇲🇰', autonym: 'Македонски'),
];
