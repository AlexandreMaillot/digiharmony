import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/bien_etre_partage/bouton_recommencer.dart';
import 'package:digiharmony_app/bien_etre_partage/dialogue_quitter_seance.dart';
import 'package:digiharmony_app/bien_etre_partage/ecran_preparation.dart';
import 'package:digiharmony_app/bien_etre_partage/indication_audio.dart';
import 'package:digiharmony_app/bien_etre_partage/mise_en_page_celebration.dart';
import 'package:digiharmony_app/bien_etre_partage/quitter_seance.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/respiration/bloc/respiration_bloc.dart';
import 'package:digiharmony_app/pages/respiration/donnees/donnees.dart';
import 'package:digiharmony_app/pages/respiration/domaine/usecase/usecase.dart';
import 'package:digiharmony_app/pages/respiration/respiration_l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:digiharmony_app/voix_off/widgets/bouton_voix_off.dart';
import 'package:digiharmony_app/widgets/barre_outils.dart';
import 'package:digiharmony_app/widgets/fond_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Les imports digiharmony_app/respiration/donnees et domaine introduisent
// deux sous-sections avec la même racine ; le linter les considère comme des
// sections distinctes même si elles sont triées alphabétiquement.
// ignore_for_file: directives_ordering

/// Écran « Respiration » (cohérence cardiaque 4-2-6 x 5).
///
/// [RespirationPage] est un [StatelessWidget] responsable uniquement de
/// construire le [RespirationBloc] avec ses UseCases injectés via
/// [RepositoryProvider] / [BlocProvider].
/// Aucune logique métier ici.
class RespirationPage extends StatelessWidget {
  /// {@macro respiration_page}
  const RespirationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lu ici (dans build) et non dans `create` : depend du contexte.
    final langue = Localizations.localeOf(context).languageCode;
    return BlocProvider<RespirationBloc>(
      create: (context) => RespirationBloc(
        session: SeanceRespiration.quatreDeuxSix,
        enregistrerSeance: EnregistrerSeanceBienEtreUseCase(
          depot: context.read<DepotStatsBienEtre>(),
        ),
        gererAudio: GererAudioRespirationUseCase(
          depot: DepotAudioRespirationImpl(langue: langue),
        ),
        lireVoixOff: LirePreferenceVoixOffUseCase(
          voixOffBloc: context.read<VoixOffBloc>(),
        ),
      )..add(const RespirationDemarree()),
      child: const RespirationView(),
    );
  }
}

/// UI de l'écran Respiration.
///
/// Lit l'état via [BlocBuilder]/[BlocConsumer] et n'émet que des événements.
/// Aucune logique métier. Navigation/haptique autorisés (UI, pas métier).
class RespirationView extends StatelessWidget {
  /// {@macro respiration_view}
  const RespirationView({super.key});

  Future<void> _onBackPressed(BuildContext context) async {
    final bloc = context.read<RespirationBloc>();
    final l10n = context.l10n;
    final inSession = bloc.state.status != RespirationStatus.terminee;
    if (!inSession) {
      quitterEcranSeance(context);
      return;
    }
    final leave = await showDialogueQuitterSeance(
      context,
      title: l10n.breathingExitDialogTitle,
      body: l10n.breathingExitDialogBody,
      confirmLabel: l10n.breathingExitDialogConfirm,
      cancelLabel: l10n.breathingExitDialogCancel,
    );
    if ((leave ?? false) && context.mounted) {
      bloc.add(const RespirationMiseEnPause());
      quitterEcranSeance(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onBackPressed(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundDeep,
        appBar: BarreOutils(
          title: l10n.breathingTitle,
          backLabel: l10n.breathingToolbarBack,
          fermer: true,
          onBack: () => _onBackPressed(context),
          trailing: BoutonVoixOff(
            onLabel: l10n.breathingVoiceoverOnLabel,
            offLabel: l10n.breathingVoiceoverOffLabel,
          ),
        ),
        body: FondApplication(
          child: SafeArea(
            child: BlocConsumer<RespirationBloc, RespirationState>(
              listenWhen: (p, c) =>
                  p.phase != c.phase || p.status != c.status,
              listener: (context, state) {
                // Audio géré par le bloc ; ici uniquement l'haptique (UI).
                if (state.status == RespirationStatus.terminee) {
                  unawaited(HapticFeedback.mediumImpact());
                } else if (state.status == RespirationStatus.enCours) {
                  unawaited(HapticFeedback.lightImpact());
                }
              },
              builder: (context, state) => switch (state.status) {
                RespirationStatus.preparation => EcranPreparation(
                  phrase: context.l10n.breathingCountdownPrepare,
                  compteur: state.prepRestant,
                  couleur: AppColors.primary,
                ),
                RespirationStatus.enCours ||
                RespirationStatus.enPause => _LayoutEnCours(state: state),
                RespirationStatus.terminee =>
                  _LayoutCelebration(state: state),
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout en cours de séance
// ---------------------------------------------------------------------------

class _LayoutEnCours extends StatelessWidget {
  const _LayoutEnCours({required this.state});

  final RespirationState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enPause = state.status == RespirationStatus.enPause;

    return Column(
      children: [
        const Spacer(),
        GestureDetector(
          onTap: () => context
              .read<RespirationBloc>()
              .add(const RespirationPauseBasculee()),
          // Animation isolée dans BulleRespirationAnimee (StatefulWidget).
          // _LayoutEnCours reste Stateless.
          child: BulleRespirationAnimee(
            phase: state.phase,
            enPause: enPause,
            duree: Duration(seconds: state.phaseDurationSeconds),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          state.phase.label(l10n),
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.breathingSecondsValue(state.phaseDurationSeconds),
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        _PointsCycles(
          current: state.cycleIndex,
          total: SeanceRespiration.quatreDeuxSix.totalCycles,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.breathingCycleProgress(
            state.cycleNumber,
            SeanceRespiration.quatreDeuxSix.totalCycles,
          ),
          style: const TextStyle(color: AppColors.textMuted),
        ),
        if (enPause) ...[
          const SizedBox(height: 8),
          Text(
            l10n.breathingResumeHint,
            style: const TextStyle(color: AppColors.accentGold),
          ),
        ],
        const Spacer(),
        IndicationAudio(label: l10n.breathingVoiceoverHint),
        const SizedBox(height: 16),
        BoutonRecommencer(
          label: l10n.breathingRestart,
          onTap: () => context
              .read<RespirationBloc>()
              .add(const RespirationRedemarree()),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// BulleRespirationAnimee — SEUL widget StatefulWidget de la feature.
// Responsabilité unique : animer la bulle selon la phase/pause.
// La Page et la View restent entièrement Stateless.
// ---------------------------------------------------------------------------

/// Widget animé de la bulle de respiration.
///
/// Isole l'[AnimationController] dans un [StatefulWidget] dédié pour que la
/// [RespirationView] reste [StatelessWidget].
/// Respecte [MediaQueryData.disableAnimations] (reduceMotion).
class BulleRespirationAnimee extends StatefulWidget {
  /// {@macro bulle_respiration_animee}
  const BulleRespirationAnimee({
    required this.phase,
    required this.enPause,
    required this.duree,
    super.key,
  });

  /// Phase de respiration courante.
  final PhaseRespiration phase;

  /// Si `true`, la bulle affiche l'icône pause et stoppe l'animation.
  final bool enPause;

  /// Duree de la phase courante (inspire 4s / retiens 2s / expire 6s).
  final Duration duree;

  @override
  State<BulleRespirationAnimee> createState() =>
      _BulleRespirationAnimeeState();
}

class _BulleRespirationAnimeeState extends State<BulleRespirationAnimee>
    with SingleTickerProviderStateMixin {
  // Tailles min/max de la bulle (facteur d'echelle).
  static const double _petit = 0.55;
  static const double _grand = 1;

  late final AnimationController _controller;
  Animation<double> _scale = const AlwaysStoppedAnimation<double>(_petit);
  bool _initialise = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Premiere configuration apres initState (MediaQuery lisible ici).
    if (!_initialise) {
      _initialise = true;
      _appliquerPhase(nouvellePhase: true);
    }
  }

  @override
  void didUpdateWidget(BulleRespirationAnimee oldWidget) {
    super.didUpdateWidget(oldWidget);
    final phaseChangee = oldWidget.phase != widget.phase;
    if (phaseChangee || oldWidget.enPause != widget.enPause) {
      _appliquerPhase(nouvellePhase: phaseChangee);
    }
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  /// Configure l'animation selon la phase courante :
  /// inspire = grossit, retiens = fige (taille pleine), expire = retrecit.
  void _appliquerPhase({required bool nouvellePhase}) {
    // En pause : on fige l'animation a sa position courante.
    if (widget.enPause) {
      _controller.stop();
      return;
    }

    final (double debut, double fin) = switch (widget.phase) {
      PhaseRespiration.inhale => (_petit, _grand),
      PhaseRespiration.hold => (_grand, _grand),
      PhaseRespiration.exhale => (_grand, _petit),
    };

    // Retiens (ou reduceMotion) : pas de mouvement, on reste a la cible.
    if (widget.phase == PhaseRespiration.hold || _reduceMotion) {
      _controller.stop();
      setState(() => _scale = AlwaysStoppedAnimation<double>(fin));
      return;
    }

    _controller
      ..stop()
      ..duration = widget.duree;
    setState(() {
      _scale = Tween<double>(begin: debut, end: fin).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    });
    // Nouvelle phase -> depart a zero ; reprise apres pause -> on continue.
    unawaited(_controller.forward(from: nouvellePhase ? 0 : null));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: _BulleRespiration(
        phase: widget.phase,
        enPause: widget.enPause,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets Stateless internes
// ---------------------------------------------------------------------------

class _BulleRespiration extends StatelessWidget {
  const _BulleRespiration({required this.phase, required this.enPause});

  final PhaseRespiration phase;
  final bool enPause;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.5),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ),
      child: Icon(
        enPause ? Icons.pause : Icons.air,
        color: AppColors.text,
        size: 48,
      ),
    );
  }
}

class _PointsCycles extends StatelessWidget {
  const _PointsCycles({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: i == current ? 14 : 10,
              height: i == current ? 14 : 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= current
                    ? AppColors.successVert
                    : AppColors.textMuted.withValues(alpha: 0.3),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layout célébration
// ---------------------------------------------------------------------------

class _LayoutCelebration extends StatelessWidget {
  const _LayoutCelebration({required this.state});

  final RespirationState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MiseEnPageCelebration(
      title: l10n.breathingCelebrationTitle,
      body: l10n.breathingCelebrationBody,
      actions: [
        BoutonRecommencer(
          label: l10n.breathingRestart,
          onTap: () => context
              .read<RespirationBloc>()
              .add(const RespirationRedemarree()),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => quitterEcranSeance(context),
          child: Text(l10n.breathingCelebrationDone),
        ),
      ],
    );
  }
}
