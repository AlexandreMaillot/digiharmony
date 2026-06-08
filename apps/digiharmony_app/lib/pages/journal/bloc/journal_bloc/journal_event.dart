part of 'journal_bloc.dart';

/// Événements du journal d'humeur (US-8, #10).
///
/// Sealed pour exhaustivité du switch dans le Bloc.
sealed class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

/// Démarre les abonnements Drift (jour + conseil + semaine + mois courant).
///
/// Transformer : `restartable()` — relance les streams si l'event est rejoué.
final class JournalDemarre extends JournalEvent {
  const JournalDemarre();
}

/// Change la vue active (Jour / Semaine / Mois).
///
/// Transformer : `droppable()` — anti double-tap segment.
final class JournalVueChangee extends JournalEvent {
  const JournalVueChangee(this.vue);

  /// La vue cible.
  final JournalVue vue;

  @override
  List<Object?> get props => [vue];
}

/// Recule le mois affiché d'un mois et relance le stream du mois.
///
/// Transformer : `droppable()`.
final class JournalMoisPrecedent extends JournalEvent {
  const JournalMoisPrecedent();
}

/// Avance le mois affiché d'un mois **uniquement si `peutAvancerMois`**.
///
/// No-op si le mois courant est déjà atteint (DEC-J-05). Transformer :
/// `droppable()`.
final class JournalMoisSuivant extends JournalEvent {
  const JournalMoisSuivant();
}

/// Événement interne — mise à jour partielle depuis les streams Drift.
///
/// Privé : dispatché uniquement par les abonnements internes au Bloc.
final class _JournalDonneesHumeurJour extends JournalEvent {
  const _JournalDonneesHumeurJour(this.humeur);
  final EntreeHumeur? humeur;

  @override
  List<Object?> get props => [humeur];
}

/// Événement interne — mise à jour depuis le stream semaine.
final class _JournalDonneesSemaine extends JournalEvent {
  const _JournalDonneesSemaine(this.entrees);
  final List<EntreeHumeur> entrees;

  @override
  List<Object?> get props => [entrees];
}

/// Événement interne — mise à jour depuis le stream mois.
final class _JournalDonneesMois extends JournalEvent {
  const _JournalDonneesMois(this.entrees);
  final List<EntreeHumeur> entrees;

  @override
  List<Object?> get props => [entrees];
}
