import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';

/// Retourne l'état courant de la préférence voix off.
///
/// Permet au RespirationBloc de consulter ce flag sans dépendre
/// directement d'un autre Bloc.
class LirePreferenceVoixOffUseCase {
  /// {@macro lire_preference_voix_off_usecase}
  const LirePreferenceVoixOffUseCase({required VoixOffBloc voixOffBloc})
    : _voixOffBloc = voixOffBloc;

  final VoixOffBloc _voixOffBloc;

  /// Retourne `true` si la voix off est activée.
  bool appeler() => _voixOffBloc.state.active;

  /// Émet la valeur courante immédiatement, puis chaque changement d'état.
  Stream<bool> flux() async* {
    yield _voixOffBloc.state.active;
    yield* _voixOffBloc.stream.map((e) => e.active);
  }
}
