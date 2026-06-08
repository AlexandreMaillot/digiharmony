import 'package:core_package/core_package.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Wrapper testable du guide audio « Les sens » (just_audio simple).
///
/// Chargement en try/catch silencieux (fallback gracieux si asset absent).
class ControleurAudioSens {
  /// [langue] : code langue (ex. 'fr', 'en') -> sous-dossier audio.
  /// Repli automatique sur 'fr' si le fichier de la langue est absent.
  ControleurAudioSens({this.langue = _langueRepli});

  /// Code langue courant.
  final String langue;

  final AudioPlayer _player = AudioPlayer();

  static const String _dossier = 'assets/audio/senses';
  static const String _langueRepli = 'fr';

  static const Map<SensAncrage, String> _fichiers = <SensAncrage, String>{
    SensAncrage.see: 'voir.mp3',
    SensAncrage.touch: 'toucher.mp3',
    SensAncrage.hear: 'entendre.mp3',
    SensAncrage.smell: 'sentir.mp3',
    SensAncrage.taste: 'gouter.mp3',
  };

  /// Joue l'audio de guidage du sens dans la langue courante
  /// (repli sur 'fr' si le fichier de la langue n'existe pas).
  Future<void> playStep(SensAncrage sense) async {
    final fichier = _fichiers[sense];
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

  /// Stoppe l'audio.
  Future<void> stop() => _player.stop();

  /// Applique le volume en direct : [volume] doit être 0.0 ou 1.0.
  Future<void> definirVolume(double volume) => _player.setVolume(volume);

  /// Libere le lecteur.
  Future<void> dispose() => _player.dispose();
}
