import 'package:digiharmony_app/pages/rappel_priming/views/rappel_priming_view.dart';
import 'package:flutter/material.dart';

/// Page priming pré-permission pour le rappel quotidien d'humeur (DEC-R-05).
///
/// Affichée AVANT toute demande de permission native. Le RappelBloc et le
/// ServiceRappel sont transmis par AppRouter.versRappelPriming (pattern
/// identique à versSaisieHumeur/versJournal — DEC-FND-07). Pas de BlocProvider
/// local ici.
class RappelPrimingPage extends StatelessWidget {
  /// Crée la page priming.
  const RappelPrimingPage({super.key});

  /// Crée la route Material vers cette page.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const RappelPrimingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const RappelPrimingView();
  }
}
