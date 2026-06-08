import 'package:core_package/core_package.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'detox_config_etat.dart';
part 'detox_config_event.dart';

/// Selection Detox persistee (ambiance + duree), defauts Mer + 15 min.
///
/// Tolérance « flag léger » : la persistance reste dans HydratedBloc car
/// il s'agit d'une preference simple (pas de repository de prefs ni de
/// UseCase pour la selection).
class DetoxConfigBloc
    extends HydratedBloc<DetoxConfigEvent, DetoxConfigEtat> {
  /// {@macro detox_config_bloc}
  DetoxConfigBloc() : super(DetoxConfigEtat.initial()) {
    on<DetoxAmbianceSelectionnee>(_onAmbianceSelectionnee);
    on<DetoxDureeSelectionnee>(_onDureeSelectionnee);
  }

  void _onAmbianceSelectionnee(
    DetoxAmbianceSelectionnee event,
    Emitter<DetoxConfigEtat> emit,
  ) {
    emit(state.copyWith(ambianceId: event.id));
  }

  void _onDureeSelectionnee(
    DetoxDureeSelectionnee event,
    Emitter<DetoxConfigEtat> emit,
  ) {
    if (!DureeDetox.minutesAutorises.contains(event.minutes)) return;
    emit(state.copyWith(durationMinutes: event.minutes));
  }

  @override
  DetoxConfigEtat? fromJson(Map<String, dynamic> json) {
    final rawId = json['ambianceId'] as String?;
    final id = IdAmbianceDetox.values.firstWhere(
      (e) => e.name == rawId,
      orElse: () => AmbianceDetox.idParDefaut,
    );
    final min = json['durationMinutes'] as int?;
    final duration = DureeDetox.minutesAutorises.contains(min)
        ? min!
        : DureeDetox.minutesParDefaut;
    return DetoxConfigEtat(ambianceId: id, durationMinutes: duration);
  }

  @override
  Map<String, dynamic> toJson(DetoxConfigEtat state) => <String, dynamic>{
    'ambianceId': state.ambianceId.name,
    'durationMinutes': state.durationMinutes,
  };
}
