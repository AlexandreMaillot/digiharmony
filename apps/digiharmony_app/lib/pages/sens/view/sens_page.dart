// Les imports sens/donnees et sens/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/bien_etre_partage/dialogue_quitter_seance.dart';
import 'package:digiharmony_app/bien_etre_partage/indication_audio.dart';
import 'package:digiharmony_app/bien_etre_partage/mise_en_page_celebration.dart';
import 'package:digiharmony_app/bien_etre_partage/quitter_seance.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/sens/bloc/sens_bloc.dart';
import 'package:digiharmony_app/pages/sens/donnees/depot_audio_sens.dart';
import 'package:digiharmony_app/pages/sens/domaine/usecase/usecase.dart';
import 'package:digiharmony_app/pages/sens/sens_l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:digiharmony_app/voix_off/widgets/bouton_voix_off.dart';
import 'package:digiharmony_app/widgets/barre_outils.dart';
import 'package:digiharmony_app/widgets/fond_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ecran « Les sens » (ancrage 5-4-3-2-1, progression manuelle).
class SensPage extends StatelessWidget {
  /// {@macro sens_page}
  const SensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SensBloc>(
      create: (context) => SensBloc(
        exercise: ExerciceAncrage.cinqQuatreTroisDeuxUn,
        enregistrerSeance: EnregistrerSeanceBienEtreUseCase(
          depot: context.read<DepotStatsBienEtre>(),
        ),
        gererAudio: GererAudioSensUseCase(depot: DepotAudioSensImpl()),
        lireVoixOff: LirePreferenceVoixOffUseCase(
          voixOffBloc: context.read<VoixOffBloc>(),
        ),
      )..add(const SensDemarree()),
      child: const SensView(),
    );
  }
}

/// UI de l'ecran « Les sens ».
class SensView extends StatelessWidget {
  /// {@macro sens_view}
  const SensView({super.key});

  Future<void> _onBackPressed(BuildContext context) async {
    final bloc = context.read<SensBloc>();
    final l10n = context.l10n;
    final started =
        bloc.state.status != SensStatus.termine && bloc.state.stepIndex > 0;
    if (!started) {
      quitterEcranSeance(context);
      return;
    }
    final leave = await showDialogueQuitterSeance(
      context,
      title: l10n.sensesExitDialogTitle,
      body: l10n.sensesExitDialogBody,
      confirmLabel: l10n.sensesExitDialogConfirm,
      cancelLabel: l10n.sensesExitDialogCancel,
    );
    if ((leave ?? false) && context.mounted) {
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
          title: l10n.sensesTitle,
          backLabel: l10n.sensesToolbarBack,
          onBack: () => _onBackPressed(context),
          trailing: BoutonVoixOff(
            onLabel: l10n.sensesVoiceoverOnLabel,
            offLabel: l10n.sensesVoiceoverOffLabel,
          ),
        ),
        body: FondApplication(
          child: SafeArea(
            child: BlocConsumer<SensBloc, SensState>(
              listenWhen: (p, c) =>
                  p.stepIndex != c.stepIndex || p.status != c.status,
              listener: (context, state) {
                if (state.status == SensStatus.termine) {
                  unawaited(HapticFeedback.mediumImpact());
                } else {
                  unawaited(HapticFeedback.selectionClick());
                }
              },
              builder: (context, state) => switch (state.status) {
                SensStatus.enCours => _LayoutEnCours(state: state),
                SensStatus.termine => _LayoutCelebration(state: state),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LayoutEnCours extends StatelessWidget {
  const _LayoutEnCours({required this.state});

  final SensState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final step = state.step;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _IndicateurEtape(
            current: state.stepIndex,
            total: state.exercise.totalSteps,
          ),
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.27),
              ),
            ),
            child: Icon(
              step.sense.icon,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.sensesCountValue(step.count),
            style: const TextStyle(
              color: AppColors.sensesAccentOr,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            step.sense.label(l10n),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _CarteInstruction(text: step.sense.instruction(l10n)),
          const SizedBox(height: 16),
          _RecapEtapes(doneSteps: state.doneSteps),
          const Spacer(),
          IndicationAudio(label: l10n.sensesAudioHint),
          const SizedBox(height: 16),
          Row(
            children: [
              if (state.stepIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .read<SensBloc>()
                        .add(const SensPrecedentPresse()),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.sensesPrevious),
                  ),
                ),
              if (state.stepIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sensesAccentOr,
                    foregroundColor: AppColors.backgroundDeep,
                  ),
                  onPressed: () => context
                      .read<SensBloc>()
                      .add(const SensSuivantPresse()),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    state.isLastStep
                        ? l10n.sensesCelebrationDone
                        : l10n.sensesNext,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndicateurEtape extends StatelessWidget {
  const _IndicateurEtape({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.sensesStepProgress(current + 1, total),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: i == current ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: i < current
                      ? AppColors.primary.withValues(alpha: 0.55)
                      : i == current
                      ? AppColors.sensesAccentOr
                      : AppColors.textMuted.withValues(alpha: 0.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarteInstruction extends StatelessWidget {
  const _CarteInstruction({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.text),
      ),
    );
  }
}

class _RecapEtapes extends StatelessWidget {
  const _RecapEtapes({required this.doneSteps});

  final List<EtapeAncrage> doneSteps;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (doneSteps.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final s in doneSteps)
          Chip(
            avatar: const Icon(
              Icons.check,
              size: 16,
              color: AppColors.successVert,
            ),
            label: Text(l10n.sensesRecapDone(s.count, s.sense.label(l10n))),
            backgroundColor: AppColors.surface.withValues(alpha: 0.4),
          ),
      ],
    );
  }
}

class _LayoutCelebration extends StatelessWidget {
  const _LayoutCelebration({required this.state});

  final SensState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MiseEnPageCelebration(
      title: l10n.sensesCelebrationTitle,
      body: l10n.sensesCelebrationBody,
      actions: [
        FilledButton(
          onPressed: () => quitterEcranSeance(context),
          child: Text(l10n.sensesCelebrationDone),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              context.read<SensBloc>().add(const SensRedemarree()),
          child: Text(l10n.sensesRestart),
        ),
      ],
    );
  }
}
