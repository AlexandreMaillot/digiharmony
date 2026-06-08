import 'package:core_package/core_package.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Wrapper testable de la voix off « Etirement » (just_audio SIMPLE).
///
/// Chargement en try/catch silencieux (fallback gracieux si asset absent).
class ControleurAudioEtirement {
  final AudioPlayer _player = AudioPlayer();

  static const Map<IdSegmentEtirement, String> _assets =
      <IdSegmentEtirement, String>{
        IdSegmentEtirement.anchor: 'assets/audio/etirements/ancrage.mp3',
        IdSegmentEtirement.neckShoulders:
            'assets/audio/etirements/cou_epaules.mp3',
        IdSegmentEtirement.hands: 'assets/audio/etirements/mains.mp3',
        IdSegmentEtirement.restEyes: 'assets/audio/etirements/reposer_la_vue.mp3',
      };

  /// Joue l'audio de guidage du segment (si l'asset existe).
  Future<void> playSegment(IdSegmentEtirement id) async {
    final asset = _assets[id];
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
    } on Object catch (_) {}
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
