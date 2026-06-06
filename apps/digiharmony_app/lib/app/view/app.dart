import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:digiharmony_app/pages/bienvenue/bloc/bienvenue_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_page.dart';
import 'package:digiharmony_app/pages/soutien/bloc/soutien_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Racine de l'application : fournit les dépendances (base Drift + blocs
/// hydratés) au-dessus de `MaterialApp`, câble le thème foncé et la langue.
class App extends StatelessWidget {
  /// Crée l'app avec la [database] Drift unique ouverte par `bootstrap`.
  const App({required this.database, super.key});

  /// Base de données locale unique, partagée par tout l'arbre.
  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: database),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()),
          BlocProvider<BienvenueBloc>(create: (_) => BienvenueBloc()),
          BlocProvider<SoutienBloc>(create: (_) => SoutienBloc()),
        ],
        child: const AppView(),
      ),
    );
  }
}

/// Vue racine : `MaterialApp` câblé sur le thème foncé et la langue active.
class AppView extends StatelessWidget {
  /// Crée la vue racine.
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleBloc>().state.locale;
    return MaterialApp(
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // Mode foncé uniquement (DEC-003).
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DemarragePage(),
    );
  }
}
