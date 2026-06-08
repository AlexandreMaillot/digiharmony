import 'dart:async';
import 'dart:developer';

import 'package:digiharmony_app/database/base_de_donnees.dart';
import 'package:digiharmony_app/database/depot_stats_bien_etre.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// Dependances globales construites au bootstrap et fournies a l'app.
class AppDependencies {
  /// {@macro app_dependencies}
  const AppDependencies({required this.statsRepository});

  /// Agregat local des seances bien-etre (Drift).
  final DepotStatsBienEtre statsRepository;
}

Future<void> bootstrap(
  FutureOr<Widget> Function(AppDependencies deps) builder,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Persistance legere (langue, flag voix off, selection Detox).
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  // Lecture audio en arriere-plan (SEUL ecran Detox-player l'utilise) — joue
  // un asset local, aucune URL/reseau. Echec non bloquant.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.digiharmony.audio',
      androidNotificationChannelName: 'DIGIHARMONY',
    );
  } on Object catch (error, stackTrace) {
    log(
      'JustAudioBackground.init failed',
      error: error,
      stackTrace: stackTrace,
    );
  }

  final database = BaseDeDonnees();
  final deps = AppDependencies(
    statsRepository: DepotDriftStatsBienEtre(database),
  );

  runApp(await builder(deps));
}
