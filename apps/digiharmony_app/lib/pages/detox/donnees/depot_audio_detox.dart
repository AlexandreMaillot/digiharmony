import 'package:digiharmony_app/pages/detox/audio/controleur_detox_lecteur.dart';

/// Contrat du dépôt audio pour la Détox numérique.
///
/// Encapsule [ControleurDetoxLecteur] (just_audio_background) derrière une
/// interface testable. Le Bloc ne dépend jamais directement du contrôleur.
abstract class DepotAudioDetox {
  /// Demarre l'ambiance en boucle continue pour l'[asset] donné.
  Future<void> demarrer(String asset, {required String mediaTitle});

  /// Stoppe la lecture.
  Future<void> arreter();

  /// Libère les ressources du lecteur.
  Future<void> liberer();
}

/// Implémentation de [DepotAudioDetox] s'appuyant sur
/// [ControleurDetoxLecteur] (just_audio_background).
class DepotAudioDetoxImpl implements DepotAudioDetox {
  /// {@macro depot_audio_detox_impl}
  DepotAudioDetoxImpl({ControleurDetoxLecteur? controleur})
    : _controleur = controleur ?? ControleurDetoxLecteur();

  final ControleurDetoxLecteur _controleur;

  @override
  Future<void> demarrer(String asset, {required String mediaTitle}) =>
      _controleur.start(asset, mediaTitle: mediaTitle);

  @override
  Future<void> arreter() => _controleur.stop();

  @override
  Future<void> liberer() => _controleur.dispose();
}
