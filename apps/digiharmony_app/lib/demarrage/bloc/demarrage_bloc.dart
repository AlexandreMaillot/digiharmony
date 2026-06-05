import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digiharmony_app/bienvenue/bienvenue_cubit.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:flutter/foundation.dart';

part 'demarrage_event.dart';
part 'demarrage_state.dart';

/// Bloc du démarrage (splash).
///
/// Machine à états : `DemarrageInitial` → `DemarrageEnCours` →
/// `DemarragePretPourBienvenue` | `DemarragePretPourAccueil`
/// | `DemarrageErreur`.
///
/// Cœur : `max(init, dureeMinimale)` via `Future.wait([warmUp, delayed(d)])`
/// (DEC-S-ARCHI-2). Le flag « bienvenue déjà vue » est lu sur le
/// `BienvenueCubit` (DEC-S-010). En cas d'échec du warm-up Drift, l'app
/// **route quand même** selon le flag (§7).
class DemarrageBloc extends Bloc<DemarrageEvent, DemarrageState> {
  /// Crée le bloc avec la base [database] (warm-up Drift) et le
  /// [bienvenueCubit] (flag de routage).
  DemarrageBloc({
    required AppDatabase database,
    required BienvenueCubit bienvenueCubit,
  }) : _database = database,
       _bienvenueCubit = bienvenueCubit,
       super(const DemarrageInitial()) {
    on<DemarrageDemarre>(_onDemarre);
  }

  final AppDatabase _database;
  final BienvenueCubit _bienvenueCubit;

  Future<void> _onDemarre(
    DemarrageDemarre event,
    Emitter<DemarrageState> emit,
  ) async {
    emit(const DemarrageEnCours());

    final versBienvenue = !_bienvenueCubit.estBienvenueVue();

    try {
      // max(init, dureeMinimale) : on attend que LES DEUX soient finis.
      await Future.wait<void>([
        _warmUpDrift(),
        Future<void>.delayed(event.dureeMinimale),
      ]);
    } on Object {
      // Tolérance d'erreur (§7, DEC-S) : l'app doit démarrer malgré tout.
      // On respecte la durée minimale avant de router pour éviter un flash.
      await Future<void>.delayed(event.dureeMinimale);
      emit(DemarrageErreur(versBienvenue: versBienvenue));
      return;
    }

    emit(
      versBienvenue
          ? const DemarragePretPourBienvenue()
          : const DemarragePretPourAccueil(),
    );
  }

  /// Force l'ouverture paresseuse de Drift et mesure sa complétion.
  ///
  /// Une 1re requête légère (`conseilDuJour`) suffit à ouvrir la connexion.
  Future<void> _warmUpDrift() => _database.conseilDuJour(DateTime.now());
}
