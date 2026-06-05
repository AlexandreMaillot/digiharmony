import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'demarrage_event.dart';
part 'demarrage_state.dart';

/// Bloc du démarrage (splash).
///
/// Machine à états : `DemarrageInitial` → `DemarrageEnCours` →
/// `DemarragePret` | `DemarrageErreur`.
///
/// Cœur : `max(init, dureeMinimale)` via `Future.wait([warmUp, delayed(d)])`
/// (DEC-S-ARCHI-2). L'onboarding est abandonné : le Demarrage route toujours
/// vers l'Accueil (DEC-PROD-2026). En cas d'échec du warm-up Drift, l'app
/// route quand même vers l'Accueil (§7).
class DemarrageBloc extends Bloc<DemarrageEvent, DemarrageState> {
  /// Crée le bloc avec la base [database] (warm-up Drift).
  DemarrageBloc({
    required AppDatabase database,
  }) : _database = database,
       super(const DemarrageInitial()) {
    on<DemarrageDemarre>(_onDemarre, transformer: droppable());
  }

  final AppDatabase _database;

  Future<void> _onDemarre(
    DemarrageDemarre event,
    Emitter<DemarrageState> emit,
  ) async {
    emit(const DemarrageEnCours());

    try {
      // max(init, dureeMinimale) : on attend que LES DEUX soient finis.
      await Future.wait<void>([
        _warmUpDrift(),
        Future<void>.delayed(event.dureeMinimale),
      ]);
    } on Object catch (e, stack) {
      // Tolérance d'erreur (§7, DEC-S) : l'app doit démarrer malgré tout.
      // On respecte la durée minimale avant de router pour éviter un flash.
      developer.log(
        'DemarrageBloc: échec warm-up Drift — routage de secours vers Accueil',
        error: e,
        stackTrace: stack,
        name: 'demarrage',
      );
      await Future<void>.delayed(event.dureeMinimale);
      emit(const DemarrageErreur());
      return;
    }

    emit(const DemarragePret());
  }

  /// Force l'ouverture paresseuse de Drift et mesure sa complétion.
  ///
  /// Une 1re requête légère (`conseilDuJour`) suffit à ouvrir la connexion.
  Future<void> _warmUpDrift() => _database.conseilDuJour(DateTime.now());
}
