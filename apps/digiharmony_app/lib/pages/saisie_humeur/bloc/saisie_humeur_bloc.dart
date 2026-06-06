import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:equatable/equatable.dart';

part 'saisie_humeur_event.dart';
part 'saisie_humeur_state.dart';

/// Gère la logique de saisie de l'humeur du jour (US #6).
///
/// Flux en deux temps (DEC-SH-008, remplace l'enregistrement 1-tap) :
/// - [EmotionSelectionnee] → sélection visuelle seule →
///   [EmotionSelectionneeEtat] (aucune écriture Drift).
/// - [SaisieValidee] → UPSERT Drift → [EnregistrementReussi]
///   (ou [EnregistrementEchoue]). La View referme l'écran au succès.
class SaisieHumeurBloc extends Bloc<SaisieHumeurEvent, SaisieHumeurState> {
  /// Crée le bloc avec la [database] Drift injectée.
  SaisieHumeurBloc({required AppDatabase database})
    : _database = database,
      super(const SaisieInitiale()) {
    on<EmotionSelectionnee>(_onEmotionSelectionnee, transformer: restartable());
    on<SaisieValidee>(_onSaisieValidee, transformer: droppable());
  }

  final AppDatabase _database;

  /// Traite la sélection d'une émotion (pas d'écriture).
  ///
  /// Ignorée pendant un enregistrement en vol ou après succès.
  void _onEmotionSelectionnee(
    EmotionSelectionnee event,
    Emitter<SaisieHumeurState> emit,
  ) {
    if (state is EnregistrementEnCours || state is EnregistrementReussi) return;
    emit(EmotionSelectionneeEtat(event.codeEmotion));
  }

  /// Traite la validation : UPSERT de l'émotion retenue.
  ///
  /// `droppable()` : ignore les taps répétés sur Valider pendant l'écriture.
  Future<void> _onSaisieValidee(
    SaisieValidee event,
    Emitter<SaisieHumeurState> emit,
  ) async {
    final code = state.codeSelectionne;
    // Bloque aussi après succès : avec un UPSERT instantané, `droppable()` ne
    // suffit pas si le 1er handler s'est terminé avant le 2e tap
    // (double-write).
    if (code == null ||
        state is EnregistrementEnCours ||
        state is EnregistrementReussi) {
      return;
    }

    emit(EnregistrementEnCours(codeEmotion: code));

    try {
      await _database.enregistrerHumeurDuJour(code);
      emit(EnregistrementReussi(codeEmotion: code));
    } on Object catch (e) {
      emit(
        EnregistrementEchoue(
          codeEmotion: code,
          message: e.toString(),
        ),
      );
    }
  }
}
