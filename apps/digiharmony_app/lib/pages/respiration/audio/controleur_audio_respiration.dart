import 'package:core_package/core_package.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Wrapper testable de la voix off de Respiration (just_audio simple).
///
/// Tout chargement est en try/catch silencieux : un asset manquant ne casse
/// jamais la seance (fallback gracieux).
class ControleurAudioRespiration {
  /// [langue] : code langue (ex. 'fr', 'en') -> sous-dossier audio.
  /// Repli automatique sur 'fr' si le fichier de la langue est absent.
  ControleurAudioRespiration({this.langue = _langueRepli});

  /// Code langue courant.
  final String langue;

  final AudioPlayer _player = AudioPlayer();

  static const String _dossier = 'assets/audio/respiration';
  static const String _langueRepli = 'fr';

  static const Map<PhaseRespiration, String> _fichiers =
      <PhaseRespiration, String>{
    PhaseRespiration.inhale: 'inspire.mp3',
    PhaseRespiration.hold: 'retiens.mp3',
    PhaseRespiration.exhale: 'expire.mp3',
  };

  /// Joue l'audio de guidage de la phase dans la langue courante
  /// (repli sur 'fr' si le fichier de la langue n'existe pas).
  Future<void> playPhase(PhaseRespiration phase) async {
    final fichier = _fichiers[phase];
    if (fichier == null) return;
    await _jouerAvecRepli(
      '$_dossier/$langue/$fichier',
      '$_dossier/$_langueRepli/$fichier',
    );
  }

  Future<void> _jouerAvecRepli(String asset, String repli) async {
    if (await _essayer(asset)) return;
    if (asset != repli) await _essayer(repli);
  }

  Future<bool> _essayer(String asset) async {
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
      return true;
    } on Object catch (_) {
      // Asset absent (langue ou fichier manquant) -> echec silencieux.
      return false;
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
