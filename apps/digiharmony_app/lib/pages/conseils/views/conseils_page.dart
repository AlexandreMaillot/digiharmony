import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/conseils/bloc/conseils_bloc.dart';
import 'package:digiharmony_app/pages/conseils/views/conseils_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Point d'entrée de la page Conseils (US-CO-01/02, Phase 2).
///
/// Fournit le [ConseilsBloc] au sous-arbre. Accédée via
/// `AppRouter.versConseils` en push (DEC-CO-12 / DEC-FND-07).
class ConseilsPage extends StatelessWidget {
  /// Crée la page Conseils.
  const ConseilsPage({super.key});

  /// Crée la route [MaterialPageRoute] pour navigation programmatique.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ConseilsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConseilsBloc(context.read<AppDatabase>())
            ..add(const ConseilsDemarre()),
      child: const ConseilsView(),
    );
  }
}
