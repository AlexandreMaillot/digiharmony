import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:flutter/foundation.dart';

part 'accueil_event.dart';
part 'accueil_state.dart';

/// Mapping emoji par code d'émotion (7 canoniques — DEC-003).
const Map<String, String> emojiParCode = {
  'happy': '😊',
  'calm': '😌',
  'dynamic': '⚡',
  'sad': '😢',
  'angry': '😠',
  'nervous': '😰',
  'tired': '😴',
};

/// Gère l'état de l'écran Accueil.
///
/// - Écoute [AppDatabase.observerDerniereHumeurDuJour] via `watch()`.
/// - Dérive l'état A/B : `null` → état A, entrée → état B.
/// - Charge le conseil du jour via [AppDatabase.conseilDuJour].
/// - LECTURE SEULE — n'écrit jamais dans `entrees_humeur`.
/// - JAMAIS HydratedBloc pour l'humeur (DEC-001/002).
class AccueilBloc extends Bloc<AccueilEvent, AccueilState> {
  /// Crée le bloc avec la [database] Drift injectée.
  AccueilBloc({required AppDatabase database})
    : _database = database,
      super(const AccueilChargement()) {
    on<AccueilDemarre>(_onDemarre);
  }

  final AppDatabase _database;
  StreamSubscription<EntreeHumeur?>? _humeurSub;

  /// Gère [AccueilDemarre] : abonne le stream Drift + charge le conseil.
  ///
  /// Restartable : annule l'abonnement précédent avant de démarrer (HB-8).
  /// `emit.forEach` garantit la réactivité (AC3, HB-4).
  Future<void> _onDemarre(
    AccueilDemarre event,
    Emitter<AccueilState> emit,
  ) async {
    await _humeurSub?.cancel();
    _humeurSub = null;

    try {
      final conseil = await _database.conseilDuJour(DateTime.now());
      final conseilVue = ConseilDuJourVue(cle: conseil.cleConseil);

      await emit.forEach<EntreeHumeur?>(
        _database.observerDerniereHumeurDuJour(),
        onData: (entree) {
          final humeur = entree == null
              ? null
              : HumeurDuJourVue(
                  codeEmotion: entree.codeEmotion,
                  emoji: emojiParCode[entree.codeEmotion] ?? '❓',
                  noteeLe: entree.creeLe,
                );
          return AccueilPret(conseil: conseilVue, humeurDuJour: humeur);
        },
        onError: (error, stack) => const AccueilErreur(),
      );
    } on Exception {
      emit(const AccueilErreur());
    }
  }

  @override
  Future<void> close() async {
    await _humeurSub?.cancel();
    return super.close();
  }
}
