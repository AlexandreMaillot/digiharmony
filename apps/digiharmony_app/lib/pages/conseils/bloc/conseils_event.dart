part of 'conseils_bloc.dart';

/// Événements de l'écran Conseils (deck de cartes swipables).
sealed class ConseilsEvent extends Equatable {
  const ConseilsEvent();

  @override
  List<Object?> get props => [];
}

/// Ouverture de la page : lit le corpus + l'humeur du jour, compose le deck.
final class ConseilsDemarre extends ConseilsEvent {
  /// Crée l'événement de démarrage.
  const ConseilsDemarre();
}

/// Passage à la carte suivante (swipe gauche / flèche droite / tap zone droite).
final class ConseilsCarteSuivante extends ConseilsEvent {
  /// Crée l'événement carte suivante.
  const ConseilsCarteSuivante();
}

/// Passage à la carte précédente (swipe droite / flèche gauche / tap zone gauche).
final class ConseilsCartePrecedente extends ConseilsEvent {
  /// Crée l'événement carte précédente.
  const ConseilsCartePrecedente();
}

/// Synchronisation de la position après un swipe direct dans le PageView.
///
/// [index] est la source de vérité de la position courante.
final class ConseilsCarteAtteinte extends ConseilsEvent {
  /// Crée l'événement de synchronisation de position.
  const ConseilsCarteAtteinte(this.index);

  /// Index de la carte maintenant visible (0-based).
  final int index;

  @override
  List<Object?> get props => [index];
}
