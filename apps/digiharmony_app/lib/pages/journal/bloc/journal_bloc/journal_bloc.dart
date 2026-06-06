import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:equatable/equatable.dart';

part 'journal_event.dart';
part 'journal_state.dart';

/// Orchestre la vue active, la navigation mois et les 3 sources Drift.
///
/// Règles :
/// - Bloc-only (pas de Cubit), transformers explicites (DEC-J-11).
/// - Lecture Drift seule — aucune écriture.
/// - Aucun score/classement/streak stocké dans le state (DEC-J-10).
/// - `peutAvancerMois` recalculé à chaque changement de `moisAffiche`
///   (DEC-J-05).
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  /// Crée le bloc avec la [database] Drift injectée.
  JournalBloc({required AppDatabase database})
    : _database = database,
      super(
        JournalState(moisAffiche: _debutDuMois(DateTime.now())),
      ) {
    on<JournalDemarre>(_onJournalDemarre, transformer: restartable());
    on<JournalVueChangee>(_onJournalVueChangee, transformer: droppable());
    on<JournalMoisPrecedent>(
      _onJournalMoisPrecedent,
      transformer: droppable(),
    );
    on<JournalMoisSuivant>(
      _onJournalMoisSuivant,
      transformer: droppable(),
    );
    on<_JournalDonneesHumeurJour>(_onDonneesHumeurJour);
    on<_JournalDonneesSemaine>(_onDonneesSemaine);
    on<_JournalDonneesMois>(_onDonneesMois);
  }

  final AppDatabase _database;
  StreamSubscription<EntreeHumeur?>? _subJour;
  StreamSubscription<List<EntreeHumeur>>? _subSemaine;
  StreamSubscription<List<EntreeHumeur>>? _subMois;

  /// Calcule le 1er jour du mois pour [date].
  static DateTime _debutDuMois(DateTime date) =>
      DateTime(date.year, date.month);

  /// Vrai ssi [moisAffiche] est strictement avant le 1er du mois courant.
  static bool _calculerPeutAvancer(DateTime moisAffiche) {
    final moisCourant = _debutDuMois(DateTime.now());
    return moisAffiche.isBefore(moisCourant);
  }

  /// Démarre les 3 abonnements Drift (restartable).
  Future<void> _onJournalDemarre(
    JournalDemarre event,
    Emitter<JournalState> emit,
  ) async {
    // Ferme les abonnements précédents (restartable assure que
    // _onJournalDemarre est rejoué proprement).
    await _cancelSubs();

    emit(state.copyWith(status: JournalStatus.chargement));

    final maintenant = DateTime.now();
    final moisInitial = _debutDuMois(maintenant);

    // Conseil du jour (Future, résolu une fois au démarrage).
    String? cleConseil;
    try {
      final conseil = await _database.conseilDuJour(maintenant);
      cleConseil = conseil.cleConseil;
    } on Object {
      emit(state.copyWith(status: JournalStatus.erreur, erreur: true));
      return;
    }

    // Met à jour moisAffiche et conseilDuJourCle en une émission.
    emit(
      state.copyWith(
        conseilDuJourCle: () => cleConseil,
        moisAffiche: moisInitial,
        peutAvancerMois: _calculerPeutAvancer(moisInitial),
      ),
    );

    // Abonnement humeur du jour.
    _subJour = _database.observerDerniereHumeurDuJour().listen(
      (humeur) {
        if (!isClosed) add(_JournalDonneesHumeurJour(humeur));
      },
      onError: (_) {
        if (!isClosed) add(const _JournalDonneesHumeurJour(null));
      },
    );

    // Abonnement semaine courante.
    _subSemaine = _database
        .observerEntreesDeLaSemaine(maintenant)
        .listen(
          (entries) {
            if (!isClosed) add(_JournalDonneesSemaine(entries));
          },
          onError: (_) {
            if (!isClosed) add(const _JournalDonneesSemaine([]));
          },
        );

    // Abonnement mois courant.
    _subMois = _database
        .observerEntreesDuMois(moisInitial)
        .listen(
          (entries) {
            if (!isClosed) add(_JournalDonneesMois(entries));
          },
          onError: (_) {
            if (!isClosed) add(const _JournalDonneesMois([]));
          },
        );
    // Le handler retourne immédiatement ; les abonnements tournent en tâche
    // de fond et sont fermés dans [close()].
  }

  /// Relance le stream du mois pour un [mois] donné.
  void _relancerStreamMois(DateTime mois) {
    _subMois?.cancel().ignore();
    _subMois = _database
        .observerEntreesDuMois(mois)
        .listen(
          (entries) {
            if (!isClosed) add(_JournalDonneesMois(entries));
          },
          onError: (_) {
            if (!isClosed) add(const _JournalDonneesMois([]));
          },
        );
  }

  /// Annule tous les abonnements actifs.
  Future<void> _cancelSubs() async {
    await _subJour?.cancel();
    await _subSemaine?.cancel();
    await _subMois?.cancel();
    _subJour = null;
    _subSemaine = null;
    _subMois = null;
  }

  /// Change la vue active (droppable — anti double-tap).
  void _onJournalVueChangee(
    JournalVueChangee event,
    Emitter<JournalState> emit,
  ) {
    emit(state.copyWith(vueActive: event.vue));
  }

  /// Recule le mois d'un mois et relance le stream du mois.
  Future<void> _onJournalMoisPrecedent(
    JournalMoisPrecedent event,
    Emitter<JournalState> emit,
  ) async {
    final actuel = state.moisAffiche;
    final nouveau = DateTime(actuel.year, actuel.month - 1);
    final peutAvancer = _calculerPeutAvancer(nouveau);
    emit(
      state.copyWith(moisAffiche: nouveau, peutAvancerMois: peutAvancer),
    );
    _relancerStreamMois(nouveau);
  }

  /// Avance le mois d'un mois si `peutAvancerMois` est vrai (DEC-J-05).
  Future<void> _onJournalMoisSuivant(
    JournalMoisSuivant event,
    Emitter<JournalState> emit,
  ) async {
    if (!state.peutAvancerMois) return; // borné au présent
    final actuel = state.moisAffiche;
    final nouveau = DateTime(actuel.year, actuel.month + 1);
    final peutAvancer = _calculerPeutAvancer(nouveau);
    emit(
      state.copyWith(moisAffiche: nouveau, peutAvancerMois: peutAvancer),
    );
    _relancerStreamMois(nouveau);
  }

  void _onDonneesHumeurJour(
    _JournalDonneesHumeurJour event,
    Emitter<JournalState> emit,
  ) {
    emit(
      state.copyWith(
        status: JournalStatus.pret,
        humeurDuJour: () => event.humeur,
      ),
    );
  }

  void _onDonneesSemaine(
    _JournalDonneesSemaine event,
    Emitter<JournalState> emit,
  ) {
    emit(state.copyWith(entreesSemaine: event.entrees));
  }

  void _onDonneesMois(
    _JournalDonneesMois event,
    Emitter<JournalState> emit,
  ) {
    emit(state.copyWith(entreesMois: event.entrees));
  }

  @override
  Future<void> close() async {
    await _cancelSubs();
    return super.close();
  }
}
