import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/views/journal_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Point d'entrée de la page Mon Journal (US-8, #10).
///
/// Fournit le JournalBloc au sous-arbre. Accédée via
/// AppRouter.versJournal en push (DEC-J-11).
class JournalPage extends StatelessWidget {
  /// Crée la page journal.
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JournalBloc(
        database: context.read<AppDatabase>(),
      )..add(const JournalDemarre()),
      child: const JournalView(),
    );
  }
}
