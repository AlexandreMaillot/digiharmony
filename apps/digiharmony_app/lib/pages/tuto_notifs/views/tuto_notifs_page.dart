import 'package:digiharmony_app/pages/tuto_notifs/views/tuto_notifs_view.dart';
import 'package:flutter/material.dart';

/// Page « Réduire mes notifications » (tutoriel statique OS-aware).
///
/// Aucun Bloc, aucun service natif (RÉVISION 2026-06-06) : la page délègue
/// directement à la [TutoNotifsView] (état UI local pour la bascule OS).
/// Accédée via `AppRouter.versTutoNotifs` en push.
class TutoNotifsPage extends StatelessWidget {
  /// Crée la page.
  const TutoNotifsPage({super.key});

  /// Crée la route Material vers cette page.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const TutoNotifsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const TutoNotifsView();
  }
}
