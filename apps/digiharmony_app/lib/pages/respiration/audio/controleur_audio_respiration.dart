import 'package:core_package/core_package.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Wrapper testable de la voix off de Respiration (just_audio simple).
///
/// Tout chargement est en try/catch silencieux : un asset manquant ne casse
/// jamais la seance (fallback gracieux).
class ControleurAudioRespiration {
  final AudioPlayer _player = AudioPlayer();

  static const Map<PhaseRespiration, String> _assets =
      <PhaseRespiration, String>{
    PhaseRespiration.inhale: 'assets/audio/respiration/inspire.mp3',
    PhaseRespiration.hold: 'assets/audio/respiration/retiens.mp3',
    PhaseRespiration.exhale: 'assets/audio/respiration/expire.mp3',
  };

  /// Joue l'audio de guidage de la phase (si l'asset existe).
  Future<void> playPhase(PhaseRespiration phase) async {
    final asset = _assets[phase];
    if (asset == null) return;
    try {
      // just_audio_background impose une etiquette MediaItem sur chaque
      // source ; sans elle, setAudioSource leve une exception.
      await _player.setAudioSource(
        AudioSource.asset(
          asset,
          tag: MediaItem(id: asset, title: 'DIGIHARMONY'),
        ),
      );
      await _player.play();
    } on Object catch (_) {
      // Fallback gracieux : asset absent -> silence.
    }
  }

  /// Met l'audio en pause.
  Future<void> pause() => _player.pause();

  /// Reprend l'audio.
  Future<void> resume() => _player.play();

  /// Stoppe l'audio.
  Future<void> stop() => _player.stop();

  /// Applique le volume en direct : [volume] doit être 0.0 ou 1.0.
  Future<void> definirVolume(double volume) => _player.setVolume(volume);

  /// Libere le lecteur.
  Future<void> dispose() => _player.dispose();
}
