import 'package:digiharmony_app/bootstrap.dart';
import 'package:digiharmony_app/database/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/langue/langue_cubit.dart';
import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Racine de l'application DIGIHARMONY.
class App extends StatelessWidget {
  /// {@macro app}
  const App({
    required this.dependencies,
    required this.ecranInitial,
    super.key,
  });

  /// Dependances globales construites au bootstrap.
  final AppDependencies dependencies;

  /// Ecran affiche au demarrage (fourni par le `main_*.dart`).
  ///
  /// Change la valeur passee dans `main_development.dart` pour
  /// previsualiser un autre ecran sans toucher au reste de l'app.
  final Widget ecranInitial;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<DepotStatsBienEtre>.value(
      value: dependencies.statsRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<VoixOffBloc>(create: (_) => VoixOffBloc()),
          BlocProvider<LangueCubit>(create: (_) => LangueCubit()),
        ],
        child: BlocBuilder<LangueCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              theme: ThemeApplication.themeData,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ecranInitial,
            );
          },
        ),
      ),
    );
  }
}
