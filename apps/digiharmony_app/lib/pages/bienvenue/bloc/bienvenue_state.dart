part of 'bienvenue_bloc.dart';

/// État du [BienvenueBloc].
final class BienvenueState extends Equatable {
  /// Crée l'état. [estBienvenueVue] `false` = bienvenue non encore vue.
  const BienvenueState({this.estBienvenueVue = false});

  /// Indique si la bienvenue a déjà été vue.
  final bool estBienvenueVue;

  /// Retourne une copie avec les champs modifiés.
  BienvenueState copyWith({bool? estBienvenueVue}) {
    return BienvenueState(
      estBienvenueVue: estBienvenueVue ?? this.estBienvenueVue,
    );
  }

  @override
  List<Object?> get props => [estBienvenueVue];
}
