import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/respiration/donnees/depot_audio_respiration.dart';

/// Orchestre les opérations audio de la Respiration
/// via [DepotAudioRespiration].
///
/// Le Bloc ne parle jamais directement à just_audio : il passe toujours par ce
/// UseCase, qui délègue au dépôt.
class GererAudioRespirationUseCase {
  /// {@macro gerer_audio_respiration_usecase}
  const GererAudioRespirationUseCase({required DepotAudioRespiration depot})
    : _depot = depot;

  final DepotAudioRespiration _depot;

  /// Joue le son de guidage de [phase].
  Future<void> jouerPhase(PhaseRespiration phase) =>
      _depot.jouerPhase(phase);

  /// Met l'audio en pause.
  Future<void> mettreEnPause() => _depot.mettreEnPause();

  /// Reprend l'audio.
  Future<void> reprendre() => _depot.reprendre();

  /// Stoppe l'audio.
  Future<void> arreter() => _depot.arreter();

  /// Définit le volume du lecteur en direct ([actif] = true → audible).
  Future<void> definirVolume({required bool actif}) =>
      _depot.definirVolume(actif: actif);

  /// Libère les ressources du lecteur.
  Future<void> liberer() => _depot.liberer();
}
