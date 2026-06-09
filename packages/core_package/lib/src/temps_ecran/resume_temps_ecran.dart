import 'package:equatable/equatable.dart';

/// Usage d'un jour de la semaine. Donnee pure, immuable, sans I/O.
///
/// Aucune dependance Flutter/Android : c'est le repository cote app qui lit
/// l'OS et construit ces objets.
class UsageJour extends Equatable {
  /// {@macro usage_jour}
  const UsageJour({required this.weekday, required this.duration});

  /// 1 = lundi ... 7 = dimanche (convention `DateTime.weekday`).
  final int weekday;

  /// Temps d'ecran ce jour-la.
  final Duration duration;

  @override
  List<Object?> get props => <Object?>[weekday, duration];
}

/// Resume du temps d'ecran. Donnee pure, aucune dependance Flutter/Android.
///
/// Lu a la volee depuis l'OS, JAMAIS persiste (zero collecte). Invariant :
/// [days] contient 7 entrees, ordonnees lundi -> dimanche.
class ResumeTempsEcran extends Equatable {
  /// {@macro resume_temps_ecran}
  const ResumeTempsEcran({
    required this.todayDuration,
    required this.weekTotal,
    required this.days,
  });

  /// Temps d'ecran d'aujourd'hui (jauge).
  final Duration todayDuration;

  /// Total de la semaine (texte « cette semaine »).
  final Duration weekTotal;

  /// 7 entrees, ordonnees lundi -> dimanche.
  final List<UsageJour> days;

  @override
  List<Object?> get props => <Object?>[todayDuration, weekTotal, days];
}
