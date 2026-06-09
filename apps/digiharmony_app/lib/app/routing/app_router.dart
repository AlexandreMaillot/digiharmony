import 'dart:io';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_page.dart';
import 'package:digiharmony_app/pages/bienvenue/views/bienvenue_page.dart';
import 'package:digiharmony_app/pages/bulles/view/bulles_page.dart';
import 'package:digiharmony_app/pages/conseils/views/conseils_page.dart';
import 'package:digiharmony_app/pages/detox/view/detox_config_page.dart';
import 'package:digiharmony_app/pages/etirement/view/etirement_page.dart';
import 'package:digiharmony_app/pages/journal/views/journal_page.dart';
import 'package:digiharmony_app/pages/parametres/views/parametres_page.dart';
import 'package:digiharmony_app/pages/respiration/view/respiration_page.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_page.dart';
import 'package:digiharmony_app/pages/sens/view/sens_page.dart';
import 'package:digiharmony_app/pages/soutien/views/soutien_page.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran_ios.dart';
import 'package:digiharmony_app/pages/temps_ecran/views/temps_ecran_page.dart';
import 'package:digiharmony_app/pages/tuto_notifs/views/tuto_notifs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cibles de navigation centralisées (`pushReplacement`).
///
/// Une seule définition des écrans cibles, partagée par le Démarrage et les
/// futurs écrans, pour éviter la divergence de routes (DEC-FND-07).
/// Pas de `flow_builder` en Phase 1.
abstract final class AppRouter {
  /// Remplace l'écran courant par l'écran de bienvenue.
  static Future<void> versBienvenue(BuildContext context) {
    return Navigator.of(context).pushReplacement(BienvenuePage.route());
  }

  /// Remplace l'écran courant par l'accueil.
  ///
  /// Point de bascule (DEC-FND-08) : pointe sur `AccueilPage` (placeholder V1),
  /// remplacé par l'implémentation réelle de l'Accueil (US-HOME-01).
  static Future<void> versAccueil(BuildContext context) {
    return Navigator.of(context).pushReplacement(AccueilPage.route());
  }

  /// Ouvre l'écran de saisie de l'humeur (empilé, retour possible).
  ///
  /// Utilisé depuis la carte humeur de l'Accueil (état A — DEC-SH-006).
  /// `push` (pas `pushReplacement`) : le chevron permet de revenir.
  /// La [AppDatabase] est transmise explicitement pour traverser la frontière
  /// de route (le `MaterialPageRoute` crée un nouveau sous-arbre).
  static Future<void> versSaisieHumeur(BuildContext context) {
    final database = context.read<AppDatabase>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<AppDatabase>.value(
          value: database,
          child: const SaisieHumeurPage(),
        ),
      ),
    );
  }

  /// Ouvre le journal (empilé, retour possible).
  ///
  /// Utilisé depuis la carte humeur de l'Accueil (états A et B — DEC-J-11).
  /// `push` (pas `pushReplacement`) : le chevron permet de revenir.
  /// La [AppDatabase] est transmise explicitement pour traverser la frontière
  /// de route (DEC-FND-07).
  static Future<void> versJournal(BuildContext context) {
    final database = context.read<AppDatabase>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<AppDatabase>.value(
          value: database,
          child: const JournalPage(),
        ),
      ),
    );
  }

  /// Ouvre l'écran de soutien (empilé au-dessus de l'Accueil).
  ///
  /// « Plus tard » / chevron = [Navigator.pop] → retour Accueil.
  /// Déclenché uniquement par le hook post-splash (DEC-SOP-003).
  /// La page ne relit pas la base — le compteur est évalué en amont.
  /// Pas de GoRouter (DEC-FND-07).
  static Future<void> versSoutien(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SoutienPage(),
      ),
    );
  }

  /// Ouvre l'écran « Mon temps d'écran » (empilé, retour possible).
  ///
  /// Le [ServiceTempsEcran] (façade plateforme) et l'[AppDatabase] (historique
  /// journalier local) sont fournis au sous-arbre pour traverser la frontière
  /// de route. `push` (pas `pushReplacement`) : le chevron permet de revenir.
  /// Pas de GoRouter (DEC-FND-07).
  static Future<void> versTempsEcran(BuildContext context) {
    final database = context.read<AppDatabase>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AppDatabase>.value(value: database),
            RepositoryProvider<ServiceTempsEcran>(
              // Sélection de l'implémentation par plateforme (DEC-TE-14).
              // iOS → ServiceTempsEcranIos (FamilyControls + PlatformView).
              // Android → ServiceTempsEcranImpl (app_usage + MethodChannel).
              create: (_) => Platform.isIOS
                  ? ServiceTempsEcranIos()
                  : ServiceTempsEcranImpl(),
            ),
          ],
          child: const TempsEcranPage(),
        ),
      ),
    );
  }

  /// Ouvre le deck de conseils (empilé, retour possible).
  ///
  /// La [AppDatabase] est transmise explicitement (nouveau sous-arbre de
  /// route), comme `versJournal`. `push` (pas `pushReplacement`). Pas de
  /// GoRouter
  /// (DEC-FND-07 / DEC-CO-12).
  static Future<void> versConseils(BuildContext context) {
    final database = context.read<AppDatabase>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<AppDatabase>.value(
          value: database,
          child: const ConseilsPage(),
        ),
      ),
    );
  }

  /// Ouvre le hub des exercices de relaxation « Bulles »
  /// (empilé, retour possible).
  ///
  /// La [AppDatabase] est transmise explicitement pour traverser la frontière
  /// de route (DEC-FND-07). `push`. Pas de GoRouter.
  static Future<void> versBulles(BuildContext context) {
    final database = context.read<AppDatabase>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<AppDatabase>.value(
          value: database,
          child: const BullesPage(),
        ),
      ),
    );
  }

  /// Ouvre directement l'exercice de Respiration (empilé, retour possible).
  ///
  /// Utilisé depuis les cartes Conseils « émotion » (CTA « Essayer la
  /// respiration »). La [AppDatabase] est transmise explicitement pour
  /// traverser la frontière de route (DEC-FND-07). `push`. Pas de GoRouter.
  static Future<void> versRespiration(BuildContext context) {
    final depot = DepotDriftStatsBienEtre(context.read<AppDatabase>());
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const RespirationPage(),
        ),
      ),
    );
  }

  /// Ouvre la configuration de la pause « Détox » (empilé, retour possible).
  ///
  /// Utilisé depuis le CTA « Faire une pause » de l'accueil. La [AppDatabase]
  /// est transmise explicitement pour traverser la frontière de route
  /// (le lecteur Détox enregistre la séance). `push`. Pas de GoRouter.
  static Future<void> versDetox(BuildContext context) {
    final depot = DepotDriftStatsBienEtre(context.read<AppDatabase>());
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const DetoxConfigPage(),
        ),
      ),
    );
  }

  /// Ouvre directement l'exercice « Les sens » (empilé, retour possible).
  static Future<void> versSens(BuildContext context) {
    final depot = DepotDriftStatsBienEtre(context.read<AppDatabase>());
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const SensPage(),
        ),
      ),
    );
  }

  /// Ouvre directement l'exercice d'Étirement (empilé, retour possible).
  static Future<void> versEtirement(BuildContext context) {
    final depot = DepotDriftStatsBienEtre(context.read<AppDatabase>());
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const EtirementPage(),
        ),
      ),
    );
  }

  /// Ouvre le tutoriel « Réduire mes notifications » (empilé, retour possible).
  ///
  /// Tutoriel statique OS-aware (RÉVISION 2026-06-06) : aucune dépendance à
  /// transmettre, aucun service natif. `push`. Pas de GoRouter (DEC-FND-07).
  static Future<void> versTutoNotifs(BuildContext context) {
    return Navigator.of(context).push(TutoNotifsPage.route());
  }

  /// Ouvre l'écran « Paramètres » (empilé, retour possible).
  ///
  /// LocaleBloc est déjà fourni au-dessus de MaterialApp (bootstrap) :
  /// rien à transmettre à travers la frontière de route. `push`.
  /// Pas de GoRouter (DEC-FND-07, DEC-PARAM-11).
  static Future<void> versParametres(BuildContext context) {
    return Navigator.of(context).push(ParametresPage.route());
  }
}
