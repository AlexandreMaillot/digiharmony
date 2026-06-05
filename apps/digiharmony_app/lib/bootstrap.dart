import 'dart:async';
import 'dart:developer';

import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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

/// Construit le storage HydratedBloc de production (dossier documents).
Future<Storage> _defaultStorageBuilder() async {
  final dir = await getApplicationDocumentsDirectory();
  return HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(dir.path),
  );
}

/// Initialise le socle puis lance l'application.
///
/// Ordre **critique** (DEC-FND-05) : `HydratedBloc.storage` est affecté
/// **avant** `runApp` (donc avant tout cubit hydraté `Locale`/`Bienvenue`),
/// sinon ces cubits lèvent à la construction. La base Drift unique est ouverte
/// ici et fournie à l'app via [builder].
///
/// [storageBuilder] et [databaseBuilder] sont **injectables** pour les tests
/// (storage mocké + base Drift en mémoire) afin d'éviter tout I/O disque réel ;
/// en production, les fabriques par défaut sont utilisées.
Future<void> bootstrap(
  FutureOr<Widget> Function(AppDatabase database) builder, {
  Future<Storage> Function()? storageBuilder,
  AppDatabase Function()? databaseBuilder,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // 1) Storage HydratedBloc — AVANT tout cubit hydraté (hydrated_bloc 11).
  HydratedBloc.storage = await (storageBuilder ?? _defaultStorageBuilder)();

  // 2) Base Drift unique (ouverture paresseuse ; warm-up mesuré par le Splash).
  final database = (databaseBuilder ?? AppDatabase.new)();

  runApp(await builder(database));
}
