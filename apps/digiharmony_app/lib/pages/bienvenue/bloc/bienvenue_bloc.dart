import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'bienvenue_event.dart';
part 'bienvenue_state.dart';

/// Indique si l'écran de bienvenue a été vu (flag léger persistant).
///
/// Défaut `false`. Persiste via HydratedBloc sous la clé `'bienvenue'`
/// (DEC-FND-08). Le Splash lit cet état pour router vers Bienvenue ou Accueil.
class BienvenueBloc extends HydratedBloc<BienvenueEvent, BienvenueState> {
  /// Démarre avec la bienvenue non vue.
  BienvenueBloc() : super(const BienvenueState()) {
    on<BienvenueTerminee>(_onBienvenueTerminee);
  }

  /// Clé de stockage HydratedBloc dédiée.
  @override
  String get id => 'bienvenue';

  void _onBienvenueTerminee(
    BienvenueTerminee event,
    Emitter<BienvenueState> emit,
  ) {
    emit(const BienvenueState(estBienvenueVue: true));
  }

  @override
  BienvenueState fromJson(Map<String, dynamic> json) {
    return BienvenueState(
      estBienvenueVue: json['completed'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson(BienvenueState state) => <String, dynamic>{
    'completed': state.estBienvenueVue,
  };
}
