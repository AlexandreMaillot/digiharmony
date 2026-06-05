import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_page.dart';
import 'package:digiharmony_app/pages/bienvenue/views/bienvenue_page.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_page.dart';
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
}
