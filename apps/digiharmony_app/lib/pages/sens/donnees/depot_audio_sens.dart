import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/sens/audio/controleur_audio_sens.dart';

/// Contrat du dépôt audio pour les Sens.
///
/// Permet de mocker l'audio dans les tests sans dépendre de just_audio.
abstract class DepotAudioSens {
  /// Joue l'audio de guidage du [sens].
  Future<void> jouerEtape(SensAncrage sens);

  /// Stoppe l'audio.
  Future<void> arreter();

  /// Définit le volume en direct (true → 1.0, false → 0.0).
  Future<void> definirVolume({required bool actif});

  /// Libère les ressources.
  Future<void> liberer();
}

/// Implémentation [DepotAudioSens] s'appuyant sur [ControleurAudioSens]
/// (just_audio).
class DepotAudioSensImpl implements DepotAudioSens {
  /// {@macro depot_audio_sens_impl}
  DepotAudioSensImpl({ControleurAudioSens? controleur})
    : _controleur = controleur ?? ControleurAudioSens();

  final ControleurAudioSens _controleur;

  @override
  Future<void> jouerEtape(SensAncrage sens) => _controleur.playStep(sens);

  @override
  Future<void> arreter() => _controleur.stop();

  @override
  Future<void> definirVolume({required bool actif}) =>
      _controleur.definirVolume(actif ? 1.0 : 0.0);

  @override
  Future<void> liberer() => _controleur.dispose();
}
