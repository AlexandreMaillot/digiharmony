import 'package:core_package/core_package.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Wrapper testable du guide audio « Les sens » (just_audio simple).
///
/// Chargement en try/catch silencieux (fallback gracieux si asset absent).
class ControleurAudioSens {
  final AudioPlayer _player = AudioPlayer();

  static const Map<SensAncrage, String> _assets = <SensAncrage, String>{
    SensAncrage.see: 'assets/audio/senses/voir.mp3',
    SensAncrage.touch: 'assets/audio/senses/toucher.mp3',
    SensAncrage.hear: 'assets/audio/senses/entendre.mp3',
    SensAncrage.smell: 'assets/audio/senses/sentir.mp3',
    SensAncrage.taste: 'assets/audio/senses/gouter.mp3',
  };

  /// Joue l'audio de guidage du sens (si l'asset existe).
  Future<void> playStep(SensAncrage sense) async {
    final asset = _assets[sense];
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

  /// Stoppe l'audio.
  Future<void> stop() => _player.stop();

  /// Applique le volume en direct : [volume] doit être 0.0 ou 1.0.
  Future<void> definirVolume(double volume) => _player.setVolume(volume);

  /// Libere le lecteur.
  Future<void> dispose() => _player.dispose();
}
