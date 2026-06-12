import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'rappel_event.dart';
part 'rappel_state.dart';

/// Gère l'activation, l'heure et la permission du rappel quotidien d'humeur.
///
/// State `{ actif, heure, permissionRefusee, invitationDejaProposee }` persiste
/// via HydratedBloc (DEC-R-02). Ne stocke JAMAIS « déjà noté » (DEC-001/002).
/// Le lecteur Drift `humeurDuJourEstNotee` est injecté (mockable en test).
///
/// Les fournisseurs de textes (`fournisseurTitre`/`fournisseurCorps`) sont des
/// closures retournant les chaînes localisées de notification, résolues depuis
/// la locale courante (BLOCKER-1). Défaut : chaîne anglaise non vide pour ne
/// jamais planifier avec texte vide.
class RappelBloc extends HydratedBloc<RappelEvent, RappelState> {
  /// Crée le bloc avec le [serviceRappel] et le lecteur Drift injectés.
  ///
  /// Les closures `fournisseurTitre` et `fournisseurCorps` retournent les
  /// textes localisés de la notification. Injectez-les depuis le
  /// [BuildContext] de l'`AppView` pour refléter la locale courante
  /// (BLOCKER-1 / DEC-R-04).
  RappelBloc({
    required ServiceRappel serviceRappel,
    required Future<bool> Function() humeurDuJourEstNotee,
    String Function()? fournisseurTitre,
    String Function()? fournisseurCorps,
  }) : _service = serviceRappel,
       _humeurDuJourEstNotee = humeurDuJourEstNotee,
       _fournisseurTitre =
           fournisseurTitre ?? (() => 'How are you feeling today?'),
       _fournisseurCorps =
           fournisseurCorps ?? (() => 'Take a moment to log your mood.'),
       super(const RappelState()) {
    on<RappelActivationDemandee>(
      _onActivationDemandee,
      transformer: sequential(),
    );
    on<RappelDesactive>(_onDesactive, transformer: sequential());
    on<RappelHeureChangee>(_onHeureChangee, transformer: sequential());
    on<RappelPermissionRefusee>(
      _onPermissionRefusee,
      transformer: sequential(),
    );
    on<RappelReplanificationDemandee>(
      _onReplanificationDemandee,
      transformer: droppable(),
    );
    on<RappelInvitationProposee>(
      _onInvitationProposee,
      transformer: sequential(),
    );
  }

  final ServiceRappel _service;
  final Future<bool> Function() _humeurDuJourEstNotee;
  String Function() _fournisseurTitre;
  String Function() _fournisseurCorps;

  /// Met à jour les closures de textes localisés de la notification.
  ///
  /// À appeler depuis `didChangeDependencies` (ex. dans `_RappelTextesSync`)
  /// dès que les `AppLocalizations` sont disponibles (changement de locale
  /// inclus). Garantit que la notification ne sera jamais planifiée avec un
  /// texte vide, même lors des replanifications de fond (BLOCKER-1 / DEC-R-04).
  void mettreAJourTextes({
    required String Function() titre,
    required String Function() corps,
  }) {
    _fournisseurTitre = titre;
    _fournisseurCorps = corps;
  }

  /// Activation après permission accordée (DEC-R-06).
  Future<void> _onActivationDemandee(
    RappelActivationDemandee event,
    Emitter<RappelState> emit,
  ) async {
    emit(
      state.copyWith(actif: true, permissionRefusee: false),
    );
    await _replanifier(state.heure, emit);
  }

  /// Désactivation : annule toute notification et passe actif=false.
  Future<void> _onDesactive(
    RappelDesactive event,
    Emitter<RappelState> emit,
  ) async {
    try {
      await _service.annulerTout();
    } on Object catch (error, stackTrace) {
      log(
        'RappelBloc._onDesactive annulerTout',
        error: error,
        stackTrace: stackTrace,
      );
    }
    emit(state.copyWith(actif: false));
  }

  /// Changement d'heure : met à jour l'état et replanifie si actif.
  Future<void> _onHeureChangee(
    RappelHeureChangee event,
    Emitter<RappelState> emit,
  ) async {
    emit(
      state.copyWith(
        heureHeure: event.heure.hour,
        heureMinute: event.heure.minute,
      ),
    );
    if (state.actif) {
      await _replanifier(event.heure, emit);
    }
  }

  /// Refus permission : revient à actif=false, pose le flag (DEC-R-06).
  void _onPermissionRefusee(
    RappelPermissionRefusee event,
    Emitter<RappelState> emit,
  ) {
    emit(state.copyWith(actif: false, permissionRefusee: true));
  }

  /// Replanification (démarrage/résumé/après saisie) — DEC-R-04.
  ///
  /// Réconcilie la permission OS puis replanifie si actif.
  Future<void> _onReplanificationDemandee(
    RappelReplanificationDemandee event,
    Emitter<RappelState> emit,
  ) async {
    // Réconciliation permission OS (DEC-R-06).
    if (state.actif) {
      try {
        final accordee = await _service.permissionAccordee();
        if (!accordee) {
          emit(state.copyWith(actif: false, permissionRefusee: true));
          return;
        }
      } on Object catch (error, stackTrace) {
        log(
          'RappelBloc._onReplanificationDemandee permissionAccordee',
          error: error,
          stackTrace: stackTrace,
        );
      }
      await _replanifier(state.heure, emit);
    }
  }

  /// Pose le flag one-shot `invitationDejaProposee` (DEC-R-03).
  void _onInvitationProposee(
    RappelInvitationProposee event,
    Emitter<RappelState> emit,
  ) {
    if (!state.invitationDejaProposee) {
      emit(state.copyWith(invitationDejaProposee: true));
    }
  }

  /// Replanifie la prochaine occurrence selon DEC-R-04.
  ///
  /// Résout les textes localisés via les closures injectées, garantissant
  /// que la notification n'est jamais planifiée avec titre/corps vides
  /// (BLOCKER-1). Les closures reflètent la locale courante.
  Future<void> _replanifier(
    TimeOfDay heure,
    Emitter<RappelState> emit,
  ) async {
    try {
      final dejaNoteAujourdhui = await _humeurDuJourEstNotee();
      await _service.planifierProchainRappel(
        heure: heure,
        dejaNoteAujourdhui: dejaNoteAujourdhui,
        titre: _fournisseurTitre(),
        corps: _fournisseurCorps(),
      );
    } on Object catch (error, stackTrace) {
      log('RappelBloc._replanifier', error: error, stackTrace: stackTrace);
    }
  }

  @override
  RappelState fromJson(Map<String, dynamic> json) {
    return RappelState(
      actif: (json['actif'] as bool?) ?? false,
      heureHeure: (json['heureHeure'] as int?) ?? 20,
      heureMinute: (json['heureMinute'] as int?) ?? 0,
      permissionRefusee: (json['permissionRefusee'] as bool?) ?? false,
      invitationDejaProposee:
          (json['invitationDejaProposee'] as bool?) ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson(RappelState state) {
    return <String, dynamic>{
      'actif': state.actif,
      'heureHeure': state.heureHeure,
      'heureMinute': state.heureMinute,
      'permissionRefusee': state.permissionRefusee,
      'invitationDejaProposee': state.invitationDejaProposee,
    };
  }
}
