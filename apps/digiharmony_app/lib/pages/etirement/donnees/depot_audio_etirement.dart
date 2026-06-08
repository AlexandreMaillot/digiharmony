import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/etirement/audio/controleur_audio_etirement.dart';

/// Contrat du dépôt audio pour l'Étirement.
///
/// Permet de mocker l'audio dans les tests sans dépendre de just_audio.
abstract class DepotAudioEtirement {
  /// Joue l'audio de guidage du segment identifié par [id].
  Future<void> jouerSegment(IdSegmentEtirement id);

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

/// Implémentation [DepotAudioEtirement] s'appuyant sur
/// [ControleurAudioEtirement] (just_audio).
class DepotAudioEtirementImpl implements DepotAudioEtirement {
  /// {@macro depot_audio_etirement_impl}
  DepotAudioEtirementImpl({ControleurAudioEtirement? controleur})
    : _controleur = controleur ?? ControleurAudioEtirement();

  final ControleurAudioEtirement _controleur;

  @override
  Future<void> jouerSegment(IdSegmentEtirement id) =>
      _controleur.playSegment(id);

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
