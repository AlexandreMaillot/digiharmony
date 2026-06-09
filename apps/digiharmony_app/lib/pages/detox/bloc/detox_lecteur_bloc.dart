import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/detox/domaine/usecase/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'detox_lecteur_event.dart';
part 'detox_lecteur_state.dart';

/// Machine d'etats du lecteur Detox : timer -> progression / arc / fleur.
///
/// Dépend UNIQUEMENT de [GererAudioDetoxUseCase] et de
/// [EnregistrerSeanceBienEtreUseCase]. Pas de pause (design sans pause).
/// Fin naturelle -> +1 Drift (1x garde-fou).
class DetoxLecteurBloc extends Bloc<DetoxLecteurEvent, DetoxLecteurState> {
  /// {@macro detox_lecteur_bloc}
  DetoxLecteurBloc({
    required SeanceDetox session,
    required GererAudioDetoxUseCase audioUseCase,
    required EnregistrerSeanceBienEtreUseCase enregistrerSeanceUseCase,
    required String mediaTitle,
  }) : _session = session,
       _audioUseCase = audioUseCase,
       _enregistrerSeanceUseCase = enregistrerSeanceUseCase,
       _mediaTitle = mediaTitle,
       super(
         DetoxLecteurState(
           status: DetoxLecteurStatus.enLecture,
           total: session.total,
           elapsed: Duration.zero,
         ),
       ) {
    on<DetoxLecteurDemarre>(_onStarted);
    on<DetoxLecteurTick>(_onTicked);
    on<DetoxLecteurTermine>(_onEnded);
  }

  final SeanceDetox _session;
  final GererAudioDetoxUseCase _audioUseCase;
  final EnregistrerSeanceBienEtreUseCase _enregistrerSeanceUseCase;
  final String _mediaTitle;

  static const Duration _tick = Duration(seconds: 1);
  Timer? _timer;

  void _onStarted(
    DetoxLecteurDemarre event,
    Emitter<DetoxLecteurState> emit,
  ) {
    // Le decompte ne doit JAMAIS dependre du chargement audio : on lance le
    // timer en premier, puis l'audio en best-effort (non bloquant).
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => add(const DetoxLecteurTick()));
    unawaited(
      _audioUseCase.demarrer(
        _session.audioAsset,
        mediaTitle: _mediaTitle,
      ),
    );
  }

  Future<void> _onTicked(
    DetoxLecteurTick event,
    Emitter<DetoxLecteurState> emit,
  ) async {
    if (state.status != DetoxLecteurStatus.enLecture) return;
    final next = state.elapsed + _tick;
    if (next >= state.total) {
      _timer?.cancel();
      if (state.statsPersisted) {
        emit(
          state.copyWith(
            status: DetoxLecteurStatus.termine,
            elapsed: state.total,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: DetoxLecteurStatus.termine,
          elapsed: state.total,
          statsPersisted: true,
        ),
      );
      await _audioUseCase.arreter();
      try {
        await _enregistrerSeanceUseCase.appeler('detox');
      } on Object catch (_) {}
      return;
    }
    emit(state.copyWith(elapsed: next));
  }

  Future<void> _onEnded(
    DetoxLecteurTermine event,
    Emitter<DetoxLecteurState> emit,
  ) async {
    _timer?.cancel();
    await _audioUseCase.arreter();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    unawaited(_audioUseCase.liberer());
    return super.close();
  }
}
