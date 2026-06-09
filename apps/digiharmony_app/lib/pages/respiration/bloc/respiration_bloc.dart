import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/pages/respiration/domaine/usecase/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'respiration_event.dart';
part 'respiration_state.dart';

/// Machine d'états de la respiration : timer / phases / cycles.
///
/// Séquence inhale -> hold -> exhale par cycle, 5 cycles, puis terminée
/// (écriture Drift +1 une seule fois). Le timer reprogramme un [Timer] de la
/// durée de la phase courante à chaque transition.
///
/// Dépend UNIQUEMENT de UseCases — pas de repositories ni de blocs directement.
class RespirationBloc extends Bloc<RespirationEvent, RespirationState> {
  /// {@macro respiration_bloc}
  RespirationBloc({
    required SeanceRespiration session,
    required EnregistrerSeanceBienEtreUseCase enregistrerSeance,
    required GererAudioRespirationUseCase gererAudio,
    required LirePreferenceVoixOffUseCase lireVoixOff,
  }) : _session = session,
       _enregistrerSeance = enregistrerSeance,
       _gererAudio = gererAudio,
       _lireVoixOff = lireVoixOff,
       super(RespirationState.preparation(session)) {
    unawaited(_gererAudio.definirVolume(actif: _lireVoixOff.appeler()));
    _voixOffSub = _lireVoixOff.flux().listen(
      (actif) => unawaited(_gererAudio.definirVolume(actif: actif)),
    );
    on<RespirationDemarree>(_onStarted);
    on<RespirationTickPreparation>(_onPrepTicked);
    on<RespirationTick>(_onTicked);
    on<RespirationPauseBasculee>(_onPauseToggled);
    on<RespirationMiseEnPause>(_onPaused);
    on<RespirationRedemarree>(_onRestarted);
  }

  final SeanceRespiration _session;
  final EnregistrerSeanceBienEtreUseCase _enregistrerSeance;
  final GererAudioRespirationUseCase _gererAudio;
  final LirePreferenceVoixOffUseCase _lireVoixOff;

  static const Duration _prepTick = Duration(seconds: 1);
  Timer? _timer;
  Timer? _prepTimer;
  Duration? _remaining;
  StreamSubscription<bool>? _voixOffSub;

  void _scheduleTimer(Duration duration) {
    _timer?.cancel();
    _remaining = duration;
    _timer = Timer(duration, () => add(const RespirationTick()));
  }

  /// Lance le decompte de preparation (3-2-1) — aucun audio a ce stade.
  void _demarrerPreparation(Emitter<RespirationState> emit) {
    _timer?.cancel();
    _prepTimer?.cancel();
    emit(RespirationState.preparation(_session));
    _prepTimer = Timer.periodic(
      _prepTick,
      (_) => add(const RespirationTickPreparation()),
    );
  }

  void _onStarted(RespirationDemarree event, Emitter<RespirationState> emit) {
    _demarrerPreparation(emit);
  }

  void _onPrepTicked(
    RespirationTickPreparation event,
    Emitter<RespirationState> emit,
  ) {
    if (state.status != RespirationStatus.preparation) return;
    final reste = state.prepRestant - 1;
    if (reste > 0) {
      emit(state.copyWith(prepRestant: reste));
      return;
    }
    // Decompte termine : demarrage de la seance (audio + timer de phase).
    _prepTimer?.cancel();
    emit(RespirationState.initial(_session));
    _jouerPhase(PhaseRespiration.inhale);
    _scheduleTimer(_session.inhale);
  }

  void _jouerPhase(PhaseRespiration phase) {
    unawaited(_gererAudio.jouerPhase(phase));
  }

  Future<void> _onTicked(
    RespirationTick event,
    Emitter<RespirationState> emit,
  ) async {
    if (state.status != RespirationStatus.enCours) return;

    const order = SeanceRespiration.ordrePhases;
    final currentPhaseIdx = order.indexOf(state.phase);

    if (currentPhaseIdx < order.length - 1) {
      // Phase suivante dans le même cycle.
      final next = order[currentPhaseIdx + 1];
      emit(
        state.copyWith(
          phase: next,
          phaseDurationSeconds: _session.durationOf(next).inSeconds,
        ),
      );
      _jouerPhase(next);
      _scheduleTimer(_session.durationOf(next));
      return;
    }

    // Fin du cycle.
    if (state.cycleIndex < _session.totalCycles - 1) {
      emit(
        state.copyWith(
          phase: PhaseRespiration.inhale,
          cycleIndex: state.cycleIndex + 1,
          phaseDurationSeconds: _session.inhale.inSeconds,
        ),
      );
      _jouerPhase(PhaseRespiration.inhale);
      _scheduleTimer(_session.inhale);
      return;
    }

    // Dernière phase du dernier cycle -> terminée.
    await _terminer(emit);
  }

  Future<void> _terminer(Emitter<RespirationState> emit) async {
    _timer?.cancel();
    if (state.statsPersisted) {
      emit(state.copyWith(status: RespirationStatus.terminee));
      return;
    }
    emit(
      state.copyWith(
        status: RespirationStatus.terminee,
        statsPersisted: true,
      ),
    );
    try {
      await _enregistrerSeance.appeler('breathing');
    } on Object catch (_) {
      // Écriture non bloquante : ne casse pas la célébration.
    }
    await _gererAudio.arreter();
  }

  void _onPauseToggled(
    RespirationPauseBasculee event,
    Emitter<RespirationState> emit,
  ) {
    if (state.status == RespirationStatus.enCours) {
      _timer?.cancel();
      emit(state.copyWith(status: RespirationStatus.enPause));
      unawaited(_gererAudio.mettreEnPause());
    } else if (state.status == RespirationStatus.enPause) {
      emit(state.copyWith(status: RespirationStatus.enCours));
      _scheduleTimer(_remaining ?? _session.durationOf(state.phase));
      unawaited(_gererAudio.reprendre());
    }
  }

  void _onPaused(
    RespirationMiseEnPause event,
    Emitter<RespirationState> emit,
  ) {
    _timer?.cancel();
    _prepTimer?.cancel();
    if (state.status == RespirationStatus.enCours) {
      emit(state.copyWith(status: RespirationStatus.enPause));
    }
    unawaited(_gererAudio.arreter());
  }

  void _onRestarted(
    RespirationRedemarree event,
    Emitter<RespirationState> emit,
  ) {
    // Recommencer repasse par le decompte 3-2-1.
    _demarrerPreparation(emit);
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    _prepTimer?.cancel();
    await _voixOffSub?.cancel();
    unawaited(_gererAudio.liberer());
    return super.close();
  }
}
