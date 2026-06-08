import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/etirement/domaine/usecase/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'etirement_event.dart';
part 'etirement_state.dart';

/// Machine d'etats de l'etirement : ticker multi-segments minute.
///
/// Dépend UNIQUEMENT de UseCases — pas de repositories ni de blocs directement.
class EtirementBloc extends Bloc<EtirementEvent, EtirementState> {
  /// {@macro etirement_bloc}
  EtirementBloc({
    required RoutineEtirement routine,
    required EnregistrerSeanceBienEtreUseCase enregistrerSeance,
    required GererAudioEtirementUseCase gererAudio,
    required LirePreferenceVoixOffUseCase lireVoixOff,
  }) : _routine = routine,
       _enregistrerSeance = enregistrerSeance,
       _gererAudio = gererAudio,
       _lireVoixOff = lireVoixOff,
       super(EtirementState.initial(routine)) {
    unawaited(_gererAudio.definirVolume(actif: _lireVoixOff.appeler()));
    _voixOffSub = _lireVoixOff.flux().listen(
      (actif) => unawaited(_gererAudio.definirVolume(actif: actif)),
    );
    on<EtirementDemarre>(_onStarted);
    on<EtirementTick>(_onTicked);
    on<EtirementPauseBasculee>(_onPauseToggled);
    on<EtirementMisEnPause>(_onPaused);
    on<EtirementRedemarree>(_onRestarted);
  }

  final RoutineEtirement _routine;
  final EnregistrerSeanceBienEtreUseCase _enregistrerSeance;
  final GererAudioEtirementUseCase _gererAudio;
  final LirePreferenceVoixOffUseCase _lireVoixOff;

  static const Duration _tick = Duration(milliseconds: 200);
  Timer? _timer;
  StreamSubscription<bool>? _voixOffSub;

  void _arm() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => add(const EtirementTick()));
  }

  void _jouerSegment(IdSegmentEtirement id) {
    unawaited(_gererAudio.jouerSegment(id));
  }

  void _onStarted(EtirementDemarre event, Emitter<EtirementState> emit) {
    emit(EtirementState.initial(_routine));
    _jouerSegment(_routine.segments.first.id);
    _arm();
  }

  Future<void> _onTicked(
    EtirementTick event,
    Emitter<EtirementState> emit,
  ) async {
    if (state.status != EtirementStatus.enCours) return;
    final nextElapsed = state.segmentElapsed + _tick;
    if (nextElapsed < state.segment.duration) {
      emit(state.copyWith(segmentElapsed: nextElapsed));
      return;
    }
    // Fin du segment.
    if (state.segmentIndex < _routine.totalSegments - 1) {
      final overflow = nextElapsed - state.segment.duration;
      final nextIndex = state.segmentIndex + 1;
      emit(
        state.copyWith(segmentIndex: nextIndex, segmentElapsed: overflow),
      );
      _jouerSegment(_routine.segments[nextIndex].id);
      return;
    }
    await _complete(emit);
  }

  Future<void> _complete(Emitter<EtirementState> emit) async {
    _timer?.cancel();
    if (state.statsPersisted) {
      emit(state.copyWith(status: EtirementStatus.termine));
      return;
    }
    emit(
      state.copyWith(
        status: EtirementStatus.termine,
        statsPersisted: true,
      ),
    );
    try {
      await _enregistrerSeance.appeler('stretch');
    } on Object catch (_) {}
    await _gererAudio.arreter();
  }

  void _onPauseToggled(
    EtirementPauseBasculee event,
    Emitter<EtirementState> emit,
  ) {
    if (state.status == EtirementStatus.enCours) {
      _timer?.cancel();
      emit(state.copyWith(status: EtirementStatus.enPause));
      unawaited(_gererAudio.mettreEnPause());
    } else if (state.status == EtirementStatus.enPause) {
      emit(state.copyWith(status: EtirementStatus.enCours));
      _arm();
      unawaited(_gererAudio.reprendre());
    }
  }

  void _onPaused(EtirementMisEnPause event, Emitter<EtirementState> emit) {
    _timer?.cancel();
    if (state.status == EtirementStatus.enCours) {
      emit(state.copyWith(status: EtirementStatus.enPause));
    }
    unawaited(_gererAudio.arreter());
  }

  void _onRestarted(EtirementRedemarree event, Emitter<EtirementState> emit) {
    emit(EtirementState.initial(_routine));
    _jouerSegment(_routine.segments.first.id);
    _arm();
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _voixOffSub?.cancel();
    unawaited(_gererAudio.liberer());
    return super.close();
  }
}
