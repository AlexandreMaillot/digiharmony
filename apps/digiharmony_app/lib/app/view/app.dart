import 'dart:async';

import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:digiharmony_app/pages/bienvenue/bloc/bienvenue_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_page.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_page.dart';
import 'package:digiharmony_app/pages/soutien/bloc/soutien_bloc.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:digiharmony_app/services/rappel/service_rappel_notifications.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Clé du navigateur global permettant au handler de tap notification de
/// router vers la saisie d'humeur sans contexte BuildContext (DEC-R-04).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Racine de l'application : fournit les dépendances (base Drift + blocs
/// hydratés) au-dessus de `MaterialApp`, câble le thème foncé et la langue.
class App extends StatelessWidget {
  /// Crée l'app avec la [database] Drift unique ouverte par `bootstrap`.
  const App({
    required this.database,
    ServiceRappel? serviceRappel,
    super.key,
  }) : _serviceRappel = serviceRappel;

  /// Base de données locale unique, partagée par tout l'arbre.
  final AppDatabase database;

  /// Service de notifications (injectable pour les tests — no-op mock).
  final ServiceRappel? _serviceRappel;

  @override
  Widget build(BuildContext context) {
    final service = _serviceRappel ?? ServiceRappelNotifications();
    // Brancher le handler de tap notification vers la route saisie (DEC-R-04).
    ServiceRappelNotifications.onTapNotification = (payload) {
      if (payload == 'saisie_humeur') {
        final nav = appNavigatorKey.currentState;
        if (nav != null) {
          final dbContext = nav.context;
          unawaited(
            nav.push(
              MaterialPageRoute<void>(
                builder: (_) => RepositoryProvider<AppDatabase>.value(
                  value: dbContext.read<AppDatabase>(),
                  child: const SaisieHumeurPage(),
                ),
              ),
            ),
          );
        }
      }
    };
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: database),
        RepositoryProvider<ServiceRappel>.value(value: service),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()),
          BlocProvider<BienvenueBloc>(create: (_) => BienvenueBloc()),
          BlocProvider<SoutienBloc>(create: (_) => SoutienBloc()),
          BlocProvider<VoixOffBloc>(create: (_) => VoixOffBloc()),
          BlocProvider<RappelBloc>(
            create: (ctx) => RappelBloc(
              serviceRappel: ctx.read<ServiceRappel>(),
              humeurDuJourEstNotee: () =>
                  ctx.read<AppDatabase>().humeurDuJourEstNotee(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

/// Vue racine : `MaterialApp` câblé sur le thème foncé et la langue active.
/// Dispatche [RappelReplanificationDemandee] au résumé de l'app (DEC-R-04).
class AppView extends StatefulWidget {
  /// Crée la vue racine.
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<RappelBloc>().add(const RappelReplanificationDemandee());
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleBloc>().state.locale;
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // Mode foncé uniquement (DEC-003).
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // _RappelTextesSync est un wrapper transparent qui met à jour les textes
      // localisés de notification dans le RappelBloc dès que les
      // AppLocalizations sont disponibles (y compris à chaque changement de
      // locale via didChangeDependencies). BLOCKER-1 / DEC-R-04.
      home: const _RappelTextesSync(child: DemarragePage()),
    );
  }
}

/// Widget transparent qui synchronise les textes localisés de notification
/// dans le [RappelBloc] à chaque changement de dépendance (locale incluse).
///
/// Placé comme `home` du [MaterialApp], il est dans l'arbre APRÈS le
/// [MaterialApp], donc les [AppLocalizations] sont disponibles via
/// [BuildContext]. Garantit que la notification ne sera jamais planifiée
/// avec un titre/corps vides, même lors des replanifications de fond
/// (BLOCKER-1 / DEC-R-04).
class _RappelTextesSync extends StatefulWidget {
  const _RappelTextesSync({required this.child});

  final Widget child;

  @override
  State<_RappelTextesSync> createState() => _RappelTextesSyncState();
}

class _RappelTextesSyncState extends State<_RappelTextesSync> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppLocalizations disponibles ici (en dessous du MaterialApp).
    try {
      final l10n = context.l10n;
      context.read<RappelBloc>().mettreAJourTextes(
        titre: () => l10n.rappelNotificationTitre,
        corps: () => l10n.rappelNotificationCorps,
      );
    } on Object {
      // RappelBloc absent (contexte de test sans App complet) — ignoré.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
