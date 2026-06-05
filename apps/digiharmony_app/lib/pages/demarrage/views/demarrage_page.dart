import 'package:digiharmony_app/bienvenue/bloc/bienvenue_bloc.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Écran de démarrage (splash), route initiale `/`.
///
/// Fournit le [DemarrageBloc] (warm-up Drift via `AppDatabase` + lecture du
/// flag `BienvenueBloc`) au-dessus de [DemarrageView]. Le socle (thème, Drift,
/// blocs, routing, splash natif) est fourni par les Fondations.
class DemarragePage extends StatelessWidget {
  /// Crée la page de démarrage.
  const DemarragePage({super.key});

  /// Retourne une [MaterialPage] contenant cet écran (pour le Navigator 2.0).
  static MaterialPage<void> page() =>
      const MaterialPage<void>(child: DemarragePage());

  /// Retourne une [Route] pour la navigation impérative.
  static Route<void> route() => MaterialPageRoute<void>(
    builder: (_) => const DemarragePage(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DemarrageBloc>(
      create: (context) => DemarrageBloc(
        database: context.read<AppDatabase>(),
        bienvenueBloc: context.read<BienvenueBloc>(),
      ),
      child: const DemarrageView(),
    );
  }
}
