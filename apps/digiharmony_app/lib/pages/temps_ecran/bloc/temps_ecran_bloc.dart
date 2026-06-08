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
    // Android : ouvre les réglages système ; l'état bascule au retour au
    // premier plan (TempsEcranRevenuAuPremierPlan) — pas ici.
    // iOS : déclenche requestAuthorization (dialog système, async) puis
    // recharge directement sans attendre le retour au premier plan.
    await _service.ouvrirReglagesAcces();
    if (_service.rapportEmbarque) {
      // Re-vérifie le statut après que l'utilisateur a répondu au dialog.
      await _charger(emit);
    }
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

      // Chemin iOS (rapport embarqué) : les chiffres ne traversent jamais vers
      // Dart — la PlatformView DeviceActivityReport les rend côté Swift
      // (DEC-TE-12, DEC-TE-13). Pas de Drift iOS, pas d'historique custom.
      if (_service.rapportEmbarque) {
        emit(state.copierAvec(status: TempsEcranStatus.pret));
        return;
      }

      // Chemin Android : lecture app_usage + agrégation + historique Drift.
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
      // Lit l'historique des 7 derniers jours depuis Drift.
      // Toujours 7 entrées : jours manquants = Duration.zero.
      final historiqueRaw = await _database.observerHistoriqueUsage().first;
      final historique = _construireHistorique(
        historiqueRaw,
        totalAujourdhui: resume.total,
      );
      emit(
        TempsEcranState(
          status: TempsEcranStatus.pret,
          resume: resume,
          historique: historique,
        ),
      );
    } on Object {
      emit(state.copierAvec(status: TempsEcranStatus.erreur));
    }
  }

  /// Construit une liste de 7 [EntreeHistorique] couvrant les 7 derniers jours.
  ///
  /// Fusionne les entrées Drift (passé) avec le total natif du jour courant.
  /// Les jours sans donnée reçoivent [Duration.zero] (pas de crash).
  static List<EntreeHistorique> _construireHistorique(
    List<UsageEcranJournalier> drift, {
    required Duration totalAujourdhui,
  }) {
    final now = DateTime.now();
    final aujourdhui = DateTime(now.year, now.month, now.day);

    // Index par jour normalisé → secondes Drift.
    final index = <DateTime, int>{
      for (final e in drift) e.jour: e.totalSecondes,
    };
    // Le jour courant est remplacé par le total natif (plus précis).
    index[aujourdhui] = totalAujourdhui.inSeconds;

    return [
      for (var i = 6; i >= 0; i--)
        () {
          final jour = aujourdhui.subtract(Duration(days: i));
          final secondes = index[jour] ?? 0;
          return EntreeHistorique(
            jour: jour,
            total: Duration(seconds: secondes),
          );
        }(),
    ];
  }
}
