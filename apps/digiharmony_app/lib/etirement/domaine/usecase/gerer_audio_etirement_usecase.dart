import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/etirement/donnees/depot_audio_etirement.dart';

/// Orchestre les opérations audio de l'Étirement via [DepotAudioEtirement].
///
/// Le Bloc ne parle jamais directement à just_audio : il passe toujours par ce
/// UseCase, qui délègue au dépôt.
class GererAudioEtirementUseCase {
  /// {@macro gerer_audio_etirement_usecase}
  const GererAudioEtirementUseCase({required DepotAudioEtirement depot})
    : _depot = depot;

  final DepotAudioEtirement _depot;

  /// Joue l'audio de guidage du segment [id].
  Future<void> jouerSegment(IdSegmentEtirement id) =>
      _depot.jouerSegment(id);

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
