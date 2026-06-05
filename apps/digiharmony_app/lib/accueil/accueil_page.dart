import 'package:digiharmony_app/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/accueil/view/accueil_view.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Écran Accueil — point d'entrée post-Bienvenue.
///
/// Fournit l'[AccueilBloc] (lecture Drift réactive, DEC-001/002)
/// et délègue le rendu à [AccueilView].
/// Route conceptuelle : `/accueil`.
class AccueilPage extends StatelessWidget {
  /// Crée la page d'accueil.
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccueilBloc(
        database: context.read<AppDatabase>(),
      )..add(const AccueilDemarre()),
      child: const AccueilView(),
    );
  }
}
