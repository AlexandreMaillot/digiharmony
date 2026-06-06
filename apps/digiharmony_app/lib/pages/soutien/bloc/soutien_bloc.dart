import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'soutien_event.dart';
part 'soutien_state.dart';

/// Anti-relance de l'écran de soutien (flag léger persistant, DEC-SO-004).
///
/// Montré une fois par épisode (7 saisies négatives consécutives).
/// Réarmé quand le compteur repasse sous le seuil.
/// Calqué sur BienvenueBloc (DEC-SOP-001).
/// **Pas de Drift ici** : état léger uniquement (DEC-002).
class SoutienBloc extends HydratedBloc<SoutienEvent, SoutienState> {
  /// Démarre avec l'écran de soutien non montré.
  SoutienBloc() : super(const SoutienState()) {
    on<SoutienMontre>(_onSoutienMontre, transformer: sequential());
    on<SoutienReinitialise>(_onSoutienReinitialise, transformer: sequential());
  }

  /// Clé de stockage HydratedBloc dédiée.
  @override
  String get id => 'soutien';

  void _onSoutienMontre(
    SoutienMontre event,
    Emitter<SoutienState> emit,
  ) {
    emit(const SoutienState(dejaMontrePourEpisodeEnCours: true));
  }

  void _onSoutienReinitialise(
    SoutienReinitialise event,
    Emitter<SoutienState> emit,
  ) {
    emit(const SoutienState());
  }

  @override
  SoutienState fromJson(Map<String, dynamic> json) {
    return SoutienState(
      dejaMontrePourEpisodeEnCours: json['shown'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson(SoutienState state) => <String, dynamic>{
    'shown': state.dejaMontrePourEpisodeEnCours,
  };
}
