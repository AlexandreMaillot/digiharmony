import 'package:core_package/core_package.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Wrapper testable de la voix off « Etirement » (just_audio SIMPLE).
///
/// Chargement en try/catch silencieux (fallback gracieux si asset absent).
class ControleurAudioEtirement {
  /// [langue] : code langue (ex. 'fr', 'en') -> sous-dossier audio.
  /// Repli automatique sur 'en' si le fichier de la langue est absent.
  ControleurAudioEtirement({this.langue = _langueRepli});

  /// Code langue courant.
  final String langue;

  final AudioPlayer _player = AudioPlayer();

  static const String _dossier = 'assets/audio/etirements';
  static const String _langueRepli = 'en';

  static const Map<IdSegmentEtirement, String> _fichiers =
      <IdSegmentEtirement, String>{
        IdSegmentEtirement.anchor: 'ancrage.mp3',
        IdSegmentEtirement.neckShoulders: 'cou_epaules.mp3',
        IdSegmentEtirement.hands: 'mains.mp3',
        IdSegmentEtirement.restEyes: 'reposer_la_vue.mp3',
      };

  /// Joue l'audio de guidage du segment dans la langue courante
  /// (repli sur 'en' si le fichier de la langue n'existe pas).
  Future<void> playSegment(IdSegmentEtirement id) async {
    final fichier = _fichiers[id];
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
