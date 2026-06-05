import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Indique si l'écran de bienvenue a été vu (flag léger persistant).
///
/// Défaut `false`. Persiste via HydratedBloc sous la clé `'bienvenue'`
/// (DEC-FND-08). Le Splash lit cet état pour router vers Bienvenue ou Accueil.
class BienvenueCubit extends HydratedCubit<bool> {
  /// Démarre avec la bienvenue non vue.
  BienvenueCubit() : super(false);

  /// Clé de stockage HydratedBloc dédiée.
  @override
  String get id => 'bienvenue';

  /// Marque la bienvenue comme vue (écrit par la future US Bienvenue).
  void complete() => emit(true);

  /// Indique si la bienvenue a déjà été vue.
  bool estBienvenueVue() => state;

  @override
  bool fromJson(Map<String, dynamic> json) =>
      json['completed'] as bool? ?? false;

  @override
  Map<String, dynamic> toJson(bool state) =>
      <String, dynamic>{'completed': state};
}
