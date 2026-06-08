part of 'journal_bloc.dart';

/// Vue active du SegmentedControl (DEC-J-01).
enum JournalVue {
  /// Vue du jour (défaut).
  jour,

  /// Vue de la semaine.
  semaine,

  /// Vue du mois.
  mois,
}

/// Statut du chargement des données.
enum JournalStatus {
  /// État initial avant tout chargement.
  initial,

  /// Chargement en cours (streams non encore émis).
  chargement,

  /// Données disponibles (stream a émis au moins une fois).
  pret,

  /// Erreur Drift (fallback bienveillant, pas de crash).
  erreur,
}

/// État du journal d'humeur.
///
/// Aucun score, classement, streak ni comparaison inter-mois (DEC-J-10/06).
final class JournalState extends Equatable {
  const JournalState({
    required this.moisAffiche,
    this.status = JournalStatus.initial,
    this.vueActive = JournalVue.jour,
    this.humeurDuJour,
    this.conseilDuJourCle,
    this.entreesSemaine = const [],
    this.entreesMois = const [],
    this.peutAvancerMois = false,
    this.erreur = false,
  });

  /// Statut du chargement.
  final JournalStatus status;

  /// Vue active (Jour par défaut — DEC-J-01).
  final JournalVue vueActive;

  /// Humeur du jour courant (null → état vide bienveillant).
  final EntreeHumeur? humeurDuJour;

  /// Clé i18n du conseil du jour (ex. `tipDay01`).
  final String? conseilDuJourCle;

  /// Entrées de la semaine courante.
  final List<EntreeHumeur> entreesSemaine;

  /// Entrées du mois affiché.
  final List<EntreeHumeur> entreesMois;

  /// Premier jour du mois affiché (ancre de navigation — DEC-J-05).
  final DateTime moisAffiche;

  /// Vrai si on peut avancer d'un mois (false = mois courant atteint).
  ///
  /// Calculé depuis `moisAffiche` : vrai ssi `moisAffiche` est strictement
  /// avant le 1er du mois courant (DEC-J-05).
  final bool peutAvancerMois;

  /// Vrai si une erreur Drift s'est produite.
  final bool erreur;

  /// Crée une copie avec les champs fournis remplacés.
  JournalState copyWith({
    JournalStatus? status,
    JournalVue? vueActive,
    EntreeHumeur? Function()? humeurDuJour,
    String? Function()? conseilDuJourCle,
    List<EntreeHumeur>? entreesSemaine,
    List<EntreeHumeur>? entreesMois,
    DateTime? moisAffiche,
    bool? peutAvancerMois,
    bool? erreur,
  }) {
    return JournalState(
      status: status ?? this.status,
      vueActive: vueActive ?? this.vueActive,
      humeurDuJour: humeurDuJour != null ? humeurDuJour() : this.humeurDuJour,
      conseilDuJourCle: conseilDuJourCle != null
          ? conseilDuJourCle()
          : this.conseilDuJourCle,
      entreesSemaine: entreesSemaine ?? this.entreesSemaine,
      entreesMois: entreesMois ?? this.entreesMois,
      moisAffiche: moisAffiche ?? this.moisAffiche,
      peutAvancerMois: peutAvancerMois ?? this.peutAvancerMois,
      erreur: erreur ?? this.erreur,
    );
  }

  @override
  List<Object?> get props => [
    status,
    vueActive,
    humeurDuJour,
    conseilDuJourCle,
    entreesSemaine,
    entreesMois,
    moisAffiche,
    peutAvancerMois,
    erreur,
  ];
}
