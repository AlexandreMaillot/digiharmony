import 'package:digiharmony_app/pages/parametres/views/parametres_view.dart';
import 'package:flutter/material.dart';

/// Page « Paramètres » — sélection de langue + confidentialité + projet.
///
/// Accédée via `AppRouter.versParametres` en push.
/// Pas de BlocProvider ici : LocaleBloc est fourni au-dessus de
/// MaterialApp (bootstrap) et traverse naturellement la frontière de route
/// (DEC-PARAM-02/11).
class ParametresPage extends StatelessWidget {
  /// Crée la page.
  const ParametresPage({super.key});

  /// Crée la route Material vers cette page.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ParametresPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ParametresView();
  }
}
