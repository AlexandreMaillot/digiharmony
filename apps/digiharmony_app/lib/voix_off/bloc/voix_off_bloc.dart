import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'voix_off_event.dart';
part 'voix_off_state.dart';

/// Bloc gérant le flag voix off partagé par tous les exercices
/// (Respiration / Les sens / Étirement).
///
/// Persiste entre sessions via [HydratedBloc].
///
/// ⚠️ Ne contient QUE ce flag UI — jamais de journal/agrégat (DEC-002).
class VoixOffBloc extends HydratedBloc<VoixOffEvent, VoixOffEtat> {
  /// {@macro voix_off_bloc}
  VoixOffBloc() : super(const VoixOffEtat(active: true)) {
    on<VoixOffBasculee>(_onBasculee);
    on<VoixOffDefinie>(_onDefinie);
  }

  void _onBasculee(VoixOffBasculee event, Emitter<VoixOffEtat> emit) {
    emit(state.copyWith(active: !state.active));
  }

  void _onDefinie(VoixOffDefinie event, Emitter<VoixOffEtat> emit) {
    emit(state.copyWith(active: event.active));
  }

  @override
  VoixOffEtat? fromJson(Map<String, dynamic> json) {
    final enabled = json['enabled'] as bool? ?? true;
    return VoixOffEtat(active: enabled);
  }

  @override
  Map<String, dynamic>? toJson(VoixOffEtat state) =>
      <String, dynamic>{'enabled': state.active};
}
