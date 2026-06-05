part of 'accueil_bloc.dart';

/// Événements du [AccueilBloc].
sealed class AccueilEvent {
  const AccueilEvent();
}

/// Déclenche l'abonnement au stream Drift et la résolution du conseil du jour.
///
/// Restartable : un second ajout remplace l'abonnement existant.
final class AccueilDemarre extends AccueilEvent {
  const AccueilDemarre();
}
