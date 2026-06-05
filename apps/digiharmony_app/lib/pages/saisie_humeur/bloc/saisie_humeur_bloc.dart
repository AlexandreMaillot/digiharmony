import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:equatable/equatable.dart';

part 'saisie_humeur_event.dart';
part 'saisie_humeur_state.dart';

/// Gère la logique de saisie de l'humeur du jour (US #6).
///
/// - [EmotionTapee] → UPSERT Drift → [EnregistrementReussi]
///   (ou [EnregistrementEchoue]).
/// - [SaisieAnnulee] → restaure/supprime → [SaisieAnnuleeEtat].
/// - [FenetreUndoExpiree] → no-op (le pop est géré côté View).
///
/// La fenêtre d'annulation (~5 s) et le pop automatique sont pilotés par la
/// View via SnackBar Material — le Bloc ne porte pas de Timer (DEC-SH-005).
class SaisieHumeurBloc extends Bloc<SaisieHumeurEvent, SaisieHumeurState> {
  /// Crée le bloc avec la [database] Drift injectée.
  SaisieHumeurBloc({required AppDatabase database})
      : _database = database,
        super(const SaisieInitiale()) {
    on<EmotionTapee>(_onEmotionTapee, transformer: droppable());
    on<SaisieAnnulee>(_onSaisieAnnulee, transformer: droppable());
    on<FenetreUndoExpiree>(_onFenetreUndoExpiree);
  }

  final AppDatabase _database;

  /// Traite un tap sur une pastille d'émotion.
  ///
  /// `droppable()` : si un UPSERT est déjà en vol, ignore les nouveaux taps
  /// (DEC-SH-004).
  Future<void> _onEmotionTapee(
    EmotionTapee event,
    Emitter<SaisieHumeurState> emit,
  ) async {
    // Si déjà réussi et pas annulé, ignorer les re-taps (picker désactivé).
    if (state is EnregistrementReussi) return;

    emit(EnregistrementEnCours(codeEmotion: event.codeEmotion));

    try {
      final ancienne =
          await _database.enregistrerHumeurDuJour(event.codeEmotion);
      emit(
        EnregistrementReussi(
          codeEmotion: event.codeEmotion,
          ancienneEntree: ancienne,
        ),
      );
    } on Object catch (e) {
      emit(
        EnregistrementEchoue(
          codeEmotion: event.codeEmotion,
          message: e.toString(),
        ),
      );
    }
  }

  /// Traite l'annulation depuis le snackbar.
  Future<void> _onSaisieAnnulee(
    SaisieAnnulee event,
    Emitter<SaisieHumeurState> emit,
  ) async {
    final courant = state;
    if (courant is! EnregistrementReussi) return;

    try {
      await _database.annulerDerniereSaisie(
        ancienneEntree: courant.ancienneEntree,
      );
      emit(
        SaisieAnnuleeEtat(
          codeEmotionRestauree: courant.ancienneEntree?.codeEmotion,
        ),
      );
    } on Object catch (e) {
      emit(
        EnregistrementEchoue(
          codeEmotion: courant.codeEmotion,
          message: e.toString(),
        ),
      );
    }
  }

  /// La fenêtre d'annulation a expiré — le pop est géré côté View.
  void _onFenetreUndoExpiree(
    FenetreUndoExpiree event,
    Emitter<SaisieHumeurState> emit,
  ) {
    // No-op : le pop automatique vers l'Accueil est déclenché dans la View
    // via le callback `.closed` du SnackBar (DEC-SH-005).
  }
}
