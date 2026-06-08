import 'package:digiharmony_app/pages/soutien/views/soutien_view.dart';
import 'package:flutter/material.dart';

/// Écran de soutien (« Super conseil »).
///
/// Affiché automatiquement après le splash quand les 7 dernières saisies
/// sont négatives consécutives (DEC-SO-001/003). Jamais accessible
/// manuellement depuis la navigation de production.
/// Anti-relance porté par SoutienBloc (global, DEC-SOP-001).
///
/// UI complète : voir [SoutienView] (M6).
class SoutienPage extends StatelessWidget {
  /// Crée la page de soutien.
  const SoutienPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Stub M4 — UI réelle livrée en M6.
    return const SoutienView();
  }
}
