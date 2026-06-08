import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/sens/domaine/usecase/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sens_event.dart';
part 'sens_state.dart';

/// Machine d'etats de l'ancrage 5-4-3-2-1 — progression MANUELLE (sans timer).
///
/// Dépend UNIQUEMENT de UseCases — pas de repositories ni de blocs directement.
class SensBloc extends Bloc<SensEvent, SensState> {
  /// {@macro sens_bloc}
  SensBloc({
    required ExerciceAncrage exercise,
    required EnregistrerSeanceBienEtreUseCase enregistrerSeance,
    required GererAudioSensUseCase gererAudio,
    required LirePreferenceVoixOffUseCase lireVoixOff,
  }) : _enregistrerSeance = enregistrerSeance,
       _gererAudio = gererAudio,
       _lireVoixOff = lireVoixOff,
       super(SensState.initial(exercise)) {
    unawaited(_gererAudio.definirVolume(actif: _lireVoixOff.appeler()));
    _voixOffSub = _lireVoixOff.flux().listen(
      (actif) => unawaited(_gererAudio.definirVolume(actif: actif)),
    );
    on<SensDemarree>(_onStarted);
    on<SensSuivantPresse>(_onNext);
    on<SensPrecedentPresse>(_onPrevious);
    on<SensRedemarree>(_onRestarted);
  }

  final EnregistrerSeanceBienEtreUseCase _enregistrerSeance;
  final GererAudioSensUseCase _gererAudio;
  final LirePreferenceVoixOffUseCase _lireVoixOff;
  StreamSubscription<bool>? _voixOffSub;

  void _jouerEtape(SensAncrage sens) {
    unawaited(_gererAudio.jouerEtape(sens));
  }

  void _onStarted(SensDemarree event, Emitter<SensState> emit) {
    // Arrivee sur l'ecran : joue l'audio de la premiere etape affichee.
    _jouerEtape(state.exercise.steps.first.sense);
  }

  Future<void> _onNext(
    SensSuivantPresse event,
    Emitter<SensState> emit,
  ) async {
    final s = state;
    if (!s.isLastStep) {
      final next = s.stepIndex + 1;
      emit(s.copyWith(stepIndex: next));
      _jouerEtape(s.exercise.steps[next].sense);
      return;
    }
    if (s.statsPersisted) {
      emit(s.copyWith(status: SensStatus.termine));
      return;
    }
    emit(s.copyWith(status: SensStatus.termine, statsPersisted: true));
    try {
      await _enregistrerSeance.appeler('senses');
    } on Object catch (_) {}
    await _gererAudio.arreter();
  }

  void _onPrevious(SensPrecedentPresse event, Emitter<SensState> emit) {
    if (state.stepIndex > 0) {
      final prev = state.stepIndex - 1;
      emit(state.copyWith(stepIndex: prev));
      _jouerEtape(state.exercise.steps[prev].sense);
    }
  }

  void _onRestarted(SensRedemarree event, Emitter<SensState> emit) {
    emit(SensState.initial(state.exercise));
    _jouerEtape(state.exercise.steps.first.sense);
  }

  @override
  Future<void> close() async {
    await _voixOffSub?.cancel();
    unawaited(_gererAudio.liberer());
    return super.close();
  }
}
