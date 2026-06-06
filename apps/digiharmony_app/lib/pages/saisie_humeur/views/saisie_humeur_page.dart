import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page « Noter mon humeur ».
///
/// Fournit le [SaisieHumeurBloc] à la vue via [BlocProvider].
/// Accédée via AppRouter.versSaisieHumeur en push (DEC-SH-006).
class SaisieHumeurPage extends StatelessWidget {
  const SaisieHumeurPage({super.key});

  /// Crée la route Material vers cette page.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SaisieHumeurPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SaisieHumeurBloc(
        database: context.read<AppDatabase>(),
      )..add(const SaisieDemarree()),
      child: const SaisieHumeurView(),
    );
  }
}
