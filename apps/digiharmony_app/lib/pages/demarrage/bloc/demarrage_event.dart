part of 'demarrage_bloc.dart';

/// Événements du démarrage (splash).
@immutable
sealed class DemarrageEvent {
  const DemarrageEvent();
}

/// Déclenché par la `View` au `initState`.
///
/// [dureeMinimale] est **calculée par la View** selon `disableAnimations`
/// (~2,5 s en mode normal, ~0,8 s en reduced motion — DEC-S-005), pour que la
/// durée minimale perçue soit injectable et testable sans attendre réellement.
@immutable
final class DemarrageDemarre extends DemarrageEvent {
  const DemarrageDemarre({required this.dureeMinimale});

  /// Durée minimale perçue du splash (`max(init, dureeMinimale)`).
  final Duration dureeMinimale;

  @override
  bool operator ==(Object other) =>
      other is DemarrageDemarre && other.dureeMinimale == dureeMinimale;

  @override
  int get hashCode => Object.hash(DemarrageDemarre, dureeMinimale);
}
