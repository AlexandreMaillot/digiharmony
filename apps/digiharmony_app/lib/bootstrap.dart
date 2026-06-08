import 'dart:async';
import 'dart:developer';

import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:flutter/foundation.dart';
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

/// Construit le storage HydratedBloc avec split web/mobile.
Future<Storage> _defaultStorageBuilder() async {
  if (kIsWeb) {
    return HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory.web,
    );
  }
  final dir = await getApplicationDocumentsDirectory();
  return HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(dir.path),
  );
}

/// Initialise le socle puis lance l'application.
///
/// Ordre **critique** (DEC-FND-05) : `HydratedBloc.storage` est affecté
/// **avant** `runApp` (donc avant tout bloc hydraté `Locale`/`Bienvenue`),
/// sinon ces blocs lèvent à la construction. La base Drift unique est ouverte
/// ici et fournie à l'app via [builder].
///
/// [storageBuilder] et [databaseBuilder] sont **injectables** pour les tests
/// (storage mocké + base Drift en mémoire) afin d'éviter tout I/O disque réel ;
/// en production, les fabriques par défaut sont utilisées.
Future<void> bootstrap(
  FutureOr<Widget> Function(AppDatabase database) builder, {
  Future<Storage> Function()? storageBuilder,
  AppDatabase Function()? databaseBuilder,
  Future<void> Function()? audioInit,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    final stack = details.stack;
    log(
      details.exceptionAsString(),
      stackTrace: stack is StackTrace ? stack : null,
    );
  };

  Bloc.observer = const AppBlocObserver();

  // 1) Storage HydratedBloc — AVANT tout bloc hydraté (hydrated_bloc 11).
  HydratedBloc.storage = await (storageBuilder ?? _defaultStorageBuilder)();

  // 2) Lecture audio en arrière-plan (écran Détox-lecteur) — joue un asset
  // local, aucune URL/réseau. Échec non bloquant. Injectable pour les tests
  // (le canal natif ne répond pas en environnement de test → no-op).
  await (audioInit ?? _defaultAudioInit)();

  // 3) Base Drift unique (ouverture paresseuse ; warm-up mesuré par le Splash).
  final database = (databaseBuilder ?? AppDatabase.new)();

  runApp(await builder(database));
}

/// Initialise just_audio_background (échec non bloquant). Remplacé par un no-op
/// dans les tests via le paramètre `audioInit` de [bootstrap].
Future<void> _defaultAudioInit() async {
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
}
