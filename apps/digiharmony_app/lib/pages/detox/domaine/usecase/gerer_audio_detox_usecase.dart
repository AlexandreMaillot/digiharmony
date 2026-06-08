import 'package:digiharmony_app/pages/detox/donnees/depot_audio_detox.dart';

/// Orchestre les opérations audio de la Détox via [DepotAudioDetox].
///
/// Le Bloc ne parle jamais directement à just_audio : il passe toujours
/// par ce UseCase, qui délègue au dépôt.
class GererAudioDetoxUseCase {
  /// {@macro gerer_audio_detox_usecase}
  const GererAudioDetoxUseCase({required DepotAudioDetox depot})
    : _depot = depot;

  final DepotAudioDetox _depot;

  /// Démarre l'ambiance [asset] en boucle avec le titre [mediaTitle].
  Future<void> demarrer(String asset, {required String mediaTitle}) =>
      _depot.demarrer(asset, mediaTitle: mediaTitle);

  /// Stoppe la lecture.
  Future<void> arreter() => _depot.arreter();

  /// Libère les ressources du lecteur.
  Future<void> liberer() => _depot.liberer();
}
