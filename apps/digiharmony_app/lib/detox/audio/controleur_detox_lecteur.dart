import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Wrapper testable de `just_audio_background` (SEUL usage du projet).
///
/// Joue un asset local en boucle. Chargement en try/catch silencieux :
/// asset manquant -> la seance continue en silence (fallback gracieux).
class ControleurDetoxLecteur {
  final AudioPlayer _player = AudioPlayer();

  /// Demarre l'ambiance en boucle continue.
  Future<void> start(String asset, {required String mediaTitle}) async {
    try {
      await _player.setLoopMode(LoopMode.one);
      await _player.setAudioSource(
        AudioSource.asset(
          asset,
          tag: MediaItem(
            id: asset,
            title: mediaTitle,
            artist: 'DIGIHARMONY',
          ),
        ),
      );
      // NE PAS attendre : en boucle (LoopMode.one), le Future de play() ne se
      // termine jamais. L'attendre bloquerait l'appelant (timer fige).
      unawaited(_player.play());
    } on Object catch (_) {
      // Fallback gracieux : asset absent -> silence, la seance continue.
    }
  }

  /// Stoppe la lecture.
  Future<void> stop() => _player.stop();

  /// Libere le lecteur (notification background retiree).
  Future<void> dispose() => _player.dispose();
}
