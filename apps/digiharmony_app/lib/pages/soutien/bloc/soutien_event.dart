part of 'soutien_bloc.dart';

/// Événements du [SoutienBloc].
sealed class SoutienEvent {
  const SoutienEvent();
}

/// Marque l'écran de soutien comme affiché pour l'épisode en cours.
///
/// Appelé À L'AFFICHAGE (DEC-SO-004), pas à la sortie.
final class SoutienMontre extends SoutienEvent {
  const SoutienMontre();
}

/// Réarme l'anti-relance quand le compteur repasse sous le seuil.
///
/// Permet à un nouvel épisode de déclenchement d'être montré.
final class SoutienReinitialise extends SoutienEvent {
  const SoutienReinitialise();
}
