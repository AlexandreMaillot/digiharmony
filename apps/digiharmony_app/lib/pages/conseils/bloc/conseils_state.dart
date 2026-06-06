part of 'conseils_bloc.dart';

/// Statuts de l'écran Conseils.
enum ConseilsStatus {
  /// Avant le premier événement (transitoire).
  initial,

  /// Lecture Drift + composition du deck en cours.
  chargement,

  /// Deck composé et prêt à afficher (≥ 1 carte).
  pret,

  /// Exception ou corpus vide → fallback bienveillant (jamais de crash).
  erreur,
}

/// État de l'écran Conseils.
///
/// Aucun champ de score / progression / badge (DEC-003 + DEC-CO-09).
final class ConseilsState extends Equatable {
  /// Crée un état Conseils.
  const ConseilsState({
    this.status = ConseilsStatus.initial,
    this.deck = const [],
    this.indexCourant = 0,
  });

  /// Statut courant.
  final ConseilsStatus status;

  /// Deck composé (vide jusqu'à [ConseilsStatus.pret]).
  final List<CarteConseil> deck;

  /// Index de la carte active (0-based).
  final int indexCourant;

  // ── Dérivés ────────────────────────────────────────────────────────────

  /// Carte courante, ou null si le deck est vide.
  CarteConseil? get carteCourante =>
      deck.isEmpty ? null : deck[indexCourant.clamp(0, deck.length - 1)];

  /// Vrai si une carte précédente existe.
  bool get aPrecedent => indexCourant > 0;

  /// Vrai si une carte suivante existe.
  bool get aSuivant => indexCourant < deck.length - 1;

  /// Copie avec champs modifiés.
  ConseilsState copierAvec({
    ConseilsStatus? status,
    List<CarteConseil>? deck,
    int? indexCourant,
  }) {
    return ConseilsState(
      status: status ?? this.status,
      deck: deck ?? this.deck,
      indexCourant: indexCourant ?? this.indexCourant,
    );
  }

  @override
  List<Object?> get props => [status, deck, indexCourant];
}
