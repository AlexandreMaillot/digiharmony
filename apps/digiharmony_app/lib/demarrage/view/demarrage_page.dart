import 'package:digiharmony_app/bienvenue/bienvenue_cubit.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/demarrage/view/demarrage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Écran de démarrage (splash), route initiale `/`.
///
/// Fournit le [DemarrageBloc] (warm-up Drift via `AppDatabase` + lecture du
/// flag `BienvenueCubit`) au-dessus de [DemarrageView]. Le socle (thème, Drift,
/// cubits, routing, splash natif) est fourni par les Fondations.
class DemarragePage extends StatelessWidget {
  /// Crée la page de démarrage.
  const DemarragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DemarrageBloc>(
      create: (context) => DemarrageBloc(
        database: context.read<AppDatabase>(),
        bienvenueCubit: context.read<BienvenueCubit>(),
      ),
      child: const DemarrageView(),
    );
  }
}
