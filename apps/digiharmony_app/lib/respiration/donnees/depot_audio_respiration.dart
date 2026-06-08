import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/respiration/audio/controleur_audio_respiration.dart';

/// Contrat du dépôt audio pour la Respiration.
///
/// Permet de mocker l'audio dans les tests sans dépendre de just_audio.
abstract class DepotAudioRespiration {
  /// Joue le son de guidage de [phase].
  Future<void> jouerPhase(PhaseRespiration phase);

  /// Met l'audio en pause.
  Future<void> mettreEnPause();

  /// Reprend l'audio.
  Future<void> reprendre();

  /// Stoppe l'audio.
  Future<void> arreter();

  /// Définit le volume en direct (true → 1.0, false → 0.0).
  Future<void> definirVolume({required bool actif});

  /// Libère les ressources.
  Future<void> liberer();
}

/// Implémentation [DepotAudioRespiration] s'appuyant sur
/// [ControleurAudioRespiration] (just_audio).
class DepotAudioRespirationImpl implements DepotAudioRespiration {
  /// {@macro depot_audio_respiration_impl}
  DepotAudioRespirationImpl({ControleurAudioRespiration? controleur})
    : _controleur = controleur ?? ControleurAudioRespiration();

  final ControleurAudioRespiration _controleur;

  @override
  Future<void> jouerPhase(PhaseRespiration phase) =>
      _controleur.playPhase(phase);

  @override
  Future<void> mettreEnPause() => _controleur.pause();

  @override
  Future<void> reprendre() => _controleur.resume();

  @override
  Future<void> arreter() => _controleur.stop();

  @override
  Future<void> definirVolume({required bool actif}) =>
      _controleur.definirVolume(actif ? 1.0 : 0.0);

  @override
  Future<void> liberer() => _controleur.dispose();
}
