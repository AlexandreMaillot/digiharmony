import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/sens/donnees/depot_audio_sens.dart';

/// Orchestre les opérations audio des Sens via [DepotAudioSens].
///
/// Le Bloc ne parle jamais directement à just_audio : il passe toujours par ce
/// UseCase, qui délègue au dépôt.
class GererAudioSensUseCase {
  /// {@macro gerer_audio_sens_usecase}
  const GererAudioSensUseCase({required DepotAudioSens depot})
    : _depot = depot;

  final DepotAudioSens _depot;

  /// Joue l'audio de guidage du [sens].
  Future<void> jouerEtape(SensAncrage sens) => _depot.jouerEtape(sens);

  /// Stoppe l'audio.
  Future<void> arreter() => _depot.arreter();

  /// Définit le volume du lecteur en direct ([actif] = true → audible).
  Future<void> definirVolume({required bool actif}) =>
      _depot.definirVolume(actif: actif);

  /// Libère les ressources du lecteur.
  Future<void> liberer() => _depot.liberer();
}
