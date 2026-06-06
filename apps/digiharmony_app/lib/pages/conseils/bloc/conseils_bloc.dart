import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:digiharmony_app/pages/conseils/modeles/composeur_deck.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'conseils_event.dart';
part 'conseils_state.dart';

/// Bloc de l'écran Conseils (deck de cartes swipables — Phase 2).
///
/// Compose le deck de façon DÉTERMINISTE au démarrage (DEC-CO-03..06) :
/// une carte émotion contextuelle optionnelle en tête + N génériques en
/// rotation quotidienne. Aucune écriture Drift (DEC-CO-09). Bloc-only,
/// transformers explicites (règle 1-bloc-only-no-cubit).
class ConseilsBloc extends Bloc<ConseilsEvent, ConseilsState> {
  /// Crée le Bloc avec la base de données.
  ConseilsBloc(AppDatabase database)
      : _database = database,
        super(const ConseilsState()) {
    on<ConseilsDemarre>(_onDemarre, transformer: restartable());
    on<ConseilsCarteSuivante>(_onSuivante, transformer: droppable());
    on<ConseilsCartePrecedente>(_onPrecedente, transformer: droppable());
    on<ConseilsCarteAtteinte>(_onCarteAtteinte, transformer: droppable());
  }

  final AppDatabase _database;

  Future<void> _onDemarre(
    ConseilsDemarre event,
    Emitter<ConseilsState> emit,
  ) async {
    emit(state.copierAvec(status: ConseilsStatus.chargement));
    try {
      // Lecture ponctuelle (deck figé à l'ouverture — DEC-CO-06 / Q-CO-5).
      // take(1).toList() tolère un stream vide (contrairement à .first).
      final humeurs = await _database
          .observerDerniereHumeurDuJour()
          .take(1)
          .toList();
      final humeur = humeurs.isEmpty ? null : humeurs.first;
      final corpus = await _database.lireCorpusConseils();

      final deck = composerDeck(
        humeurDuJour: humeur,
        corpus: corpus,
        jour: DateTime.now(),
      );

      emit(ConseilsState(status: ConseilsStatus.pret, deck: deck));
    } on Object {
      // Fallback bienveillant : au moins une carte, jamais de crash vide.
      emit(
        const ConseilsState(
          status: ConseilsStatus.erreur,
          deck: [CarteRappel(cleContenu: 'tipDay01', accentChrome: 'primary')],
        ),
      );
    }
  }

  void _onSuivante(
    ConseilsCarteSuivante event,
    Emitter<ConseilsState> emit,
  ) {
    if (!state.aSuivant) return; // no-op à la borne droite
    emit(state.copierAvec(indexCourant: state.indexCourant + 1));
  }

  void _onPrecedente(
    ConseilsCartePrecedente event,
    Emitter<ConseilsState> emit,
  ) {
    if (!state.aPrecedent) return; // no-op à la borne gauche
    emit(state.copierAvec(indexCourant: state.indexCourant - 1));
  }

  void _onCarteAtteinte(
    ConseilsCarteAtteinte event,
    Emitter<ConseilsState> emit,
  ) {
    final max = state.deck.isEmpty ? 0 : state.deck.length - 1;
    final index = event.index.clamp(0, max);
    emit(state.copierAvec(indexCourant: index));
  }
}
