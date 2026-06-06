import 'package:equatable/equatable.dart';

/// Vue d'une app dans la répartition du temps d'écran.
///
/// ViewModel léger, sans logique. Construit par [agregeUsage] à partir des
/// données natives (`AppUsageInfo`), jamais persisté (le détail par app reste
/// éphémère — DEC-TE-04 ; seul l'agrégat total va dans Drift).
class UsageAppVue extends Equatable {
  /// Crée une vue d'usage d'app.
  const UsageAppVue({
    required this.nomApp,
    required this.packageName,
    required this.duree,
    required this.fractionDuTotal,
  });

  /// Nom lisible best-effort (voir [nomLisible]).
  final String nomApp;

  /// Identifiant technique du package (ex. `com.instagram.android`).
  final String packageName;

  /// Durée d'usage sur la fenêtre considérée.
  final Duration duree;

  /// Part de cette app sur le total (0..1) — pilote la barre de proportion.
  final double fractionDuTotal;

  @override
  List<Object?> get props => [nomApp, packageName, duree, fractionDuTotal];
}

/// Résumé agrégé du temps d'écran du jour (ViewModel).
class ResumeTempsEcran extends Equatable {
  /// Crée un résumé.
  const ResumeTempsEcran({
    required this.total,
    required this.topApps,
    required this.autres,
  });

  /// Total du jour (somme de tous les usages).
  final Duration total;

  /// Top N apps triées par durée décroissante.
  final List<UsageAppVue> topApps;

  /// Somme des apps hors top N (bucket « Autres »).
  final Duration autres;

  @override
  List<Object?> get props => [total, topApps, autres];
}

/// Agrège une liste d'usages bruts en [ResumeTempsEcran] (fonction pure).
///
/// - Filtre les apps de durée nulle.
/// - Trie par durée décroissante.
/// - Garde les [topN] premières, somme le reste dans « autres ».
/// - Calcule `fractionDuTotal` de chaque app sur le total.
///
/// Retourne `null` si le total est nul (l'appelant bascule alors en état
/// « vide »). Déterministe et testable isolément (AC12).
ResumeTempsEcran? agregeUsage(
  List<UsageAppVue> usages, {
  int topN = 5,
}) {
  final filtres = usages.where((u) => u.duree > Duration.zero).toList()
    ..sort((a, b) => b.duree.compareTo(a.duree));

  final totalSecondes = filtres.fold<int>(
    0,
    (somme, u) => somme + u.duree.inSeconds,
  );
  if (totalSecondes == 0) return null;
  final total = Duration(seconds: totalSecondes);

  final top = filtres.take(topN).toList();
  final reste = filtres.skip(topN).toList();
  final autresSecondes = reste.fold<int>(
    0,
    (somme, u) => somme + u.duree.inSeconds,
  );

  final topAvecFraction = [
    for (final u in top)
      UsageAppVue(
        nomApp: u.nomApp,
        packageName: u.packageName,
        duree: u.duree,
        fractionDuTotal: u.duree.inSeconds / totalSecondes,
      ),
  ];

  return ResumeTempsEcran(
    total: total,
    topApps: topAvecFraction,
    autres: Duration(seconds: autresSecondes),
  );
}

/// Dérive un nom lisible best-effort depuis un package name (DEC-TE-06).
///
/// `app_usage` ne donne pas le libellé marketing : on prend le segment
/// significatif du package (ex. `com.instagram.android` → `Instagram`),
/// en ignorant les segments génériques de tête/queue (`com`, `android`, `app`).
/// Fonction pure, testable isolément (AC12).
String nomLisible(String packageName) {
  if (packageName.isEmpty) return packageName;
  const generiques = {'com', 'android', 'app', 'www', 'org', 'net', 'io'};
  final segments = packageName.split('.').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return packageName;

  // Cherche le premier segment non générique en partant de la fin, puis du
  // début, pour récupérer le « cœur » du nom (ex. instagram, whatsapp).
  String? choix;
  for (final s in segments.reversed) {
    if (!generiques.contains(s.toLowerCase())) {
      choix = s;
      break;
    }
  }
  choix ??= segments.last;
  return choix[0].toUpperCase() + choix.substring(1);
}
