import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'temps_ecran_event.dart';
part 'temps_ecran_state.dart';

/// Bloc de l'écran « Mon temps d'écran » (Bloc-only, transformers explicites).
///
/// Lit l'usage natif via [ServiceTempsEcran], agrège (helper pur [agregeUsage])
/// et persiste **uniquement l'agrégat total** du jour dans Drift (historique,
/// DEC-TE-04 révisé). Le détail par app reste éphémère.
class TempsEcranBloc extends Bloc<TempsEcranEvent, TempsEcranState> {
  /// Crée le Bloc.
  TempsEcranBloc({
    required ServiceTempsEcran service,
    required AppDatabase database,
  }) : _service = service,
       _database = database,
       super(const TempsEcranState()) {
    on<TempsEcranDemarre>(_onDemarre, transformer: restartable());
    on<TempsEcranPermissionDemandee>(
      _onPermissionDemandee,
      transformer: droppable(),
    );
    on<TempsEcranRevenuAuPremierPlan>(
      _onRevenuAuPremierPlan,
      transformer: restartable(),
    );
    on<TempsEcranReessaye>(_onReessaye, transformer: restartable());
  }

  final ServiceTempsEcran _service;
  final AppDatabase _database;

  Future<void> _onDemarre(
    TempsEcranDemarre event,
    Emitter<TempsEcranState> emit,
  ) => _charger(emit);

  Future<void> _onRevenuAuPremierPlan(
    TempsEcranRevenuAuPremierPlan event,
    Emitter<TempsEcranState> emit,
  ) => _charger(emit);

  Future<void> _onReessaye(
    TempsEcranReessaye event,
    Emitter<TempsEcranState> emit,
  ) => _charger(emit);

  Future<void> _onPermissionDemandee(
    TempsEcranPermissionDemandee event,
    Emitter<TempsEcranState> emit,
  ) async {
    // Ouvre les réglages système ; l'état bascule au retour au premier plan
    // (TempsEcranRevenuAuPremierPlan), pas ici.
    await _service.ouvrirReglagesAcces();
  }

  /// Séquence partagée par Démarre / Réessaye / RevenuAuPremierPlan.
  Future<void> _charger(Emitter<TempsEcranState> emit) async {
    if (!_service.plateformeSupportee) {
      emit(state.copierAvec(status: TempsEcranStatus.indisponible));
      return;
    }
    emit(state.copierAvec(status: TempsEcranStatus.chargement));
    try {
      final aAcces = await _service.aLAcces();
      if (!aAcces) {
        emit(state.copierAvec(status: TempsEcranStatus.permissionRequise));
        return;
      }
      final usages = await _service.usageDuJour();
      final resume = agregeUsage(usages);
      if (resume == null) {
        emit(state.copierAvec(status: TempsEcranStatus.vide));
        return;
      }
      // Persiste l'agrégat total du jour (historique local, jamais transmis).
      // Échec d'écriture non bloquant pour l'affichage.
      try {
        await _database.enregistrerUsageDuJour(resume.total);
      } on Object {
        // L'affichage reste prioritaire ; l'historique est best-effort.
      }
      emit(
        TempsEcranState(
          status: TempsEcranStatus.pret,
          resume: resume,
        ),
      );
    } on Object {
      emit(state.copierAvec(status: TempsEcranStatus.erreur));
    }
  }
}
