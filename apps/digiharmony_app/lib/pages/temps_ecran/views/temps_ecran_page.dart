import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/views/temps_ecran_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page « Mon temps d'écran ».
///
/// Fournit le [TempsEcranBloc] (alimenté par [ServiceTempsEcran] +
/// [AppDatabase] lus du sous-arbre) et démarre la séquence de lecture.
/// Accédée via `AppRouter.versTempsEcran` en push.
class TempsEcranPage extends StatelessWidget {
  /// Crée la page.
  const TempsEcranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TempsEcranBloc(
        service: context.read<ServiceTempsEcran>(),
        database: context.read<AppDatabase>(),
      )..add(const TempsEcranDemarre()),
      child: const TempsEcranView(),
    );
  }
}
