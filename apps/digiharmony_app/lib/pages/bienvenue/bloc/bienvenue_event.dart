part of 'bienvenue_bloc.dart';

/// Événements du [BienvenueBloc].
sealed class BienvenueEvent {
  const BienvenueEvent();
}

/// Marque la bienvenue comme vue (écrit par la future US Bienvenue).
final class BienvenueTerminee extends BienvenueEvent {
  const BienvenueTerminee();
}
