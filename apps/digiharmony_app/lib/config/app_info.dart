/// Informations de build de l'app (constantes, aucune dependance).
///
/// `version` doit rester synchrone avec `version:` du `pubspec.yaml`. Choix
/// d'une constante simple plutot que `package_info_plus` (evite une dependance
/// + un etat asynchrone pour un footer purement decoratif).
abstract final class AppInfo {
  /// Version affichee : « DIGIHARMONY v1.0 ».
  static const String version = '1.0';
}
