// Les imports etirement/donnees et etirement/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/bien_etre_partage/bouton_recommencer.dart';
import 'package:digiharmony_app/bien_etre_partage/dialogue_quitter_seance.dart';
import 'package:digiharmony_app/bien_etre_partage/ecran_preparation.dart';
import 'package:digiharmony_app/bien_etre_partage/indication_audio.dart';
import 'package:digiharmony_app/bien_etre_partage/mise_en_page_celebration.dart';
import 'package:digiharmony_app/bien_etre_partage/quitter_seance.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/pages/etirement/bloc/etirement_bloc.dart';
import 'package:digiharmony_app/pages/etirement/donnees/depot_audio_etirement.dart';
import 'package:digiharmony_app/pages/etirement/domaine/usecase/usecase.dart';
import 'package:digiharmony_app/pages/etirement/etirement_l10n.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:digiharmony_app/voix_off/widgets/bouton_voix_off.dart';
import 'package:digiharmony_app/widgets/barre_outils.dart';
import 'package:digiharmony_app/widgets/fond_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ecran « Etirement » (routine 4 segments minutee, progression auto).
class EtirementPage extends StatelessWidget {
  /// {@macro etirement_page}
  const EtirementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lu ici (dans build) et non dans `create` : depend du contexte.
    final langue = Localizations.localeOf(context).languageCode;
    return BlocProvider<EtirementBloc>(
      create: (context) => EtirementBloc(
        routine: RoutineEtirement.routineParDefaut,
        enregistrerSeance: EnregistrerSeanceBienEtreUseCase(
          depot: context.read<DepotStatsBienEtre>(),
        ),
        gererAudio: GererAudioEtirementUseCase(
          depot: DepotAudioEtirementImpl(langue: langue),
        ),
        lireVoixOff: LirePreferenceVoixOffUseCase(
          voixOffBloc: context.read<VoixOffBloc>(),
        ),
      )..add(const EtirementDemarre()),
      child: const EtirementView(),
    );
  }
}

/// UI de l'ecran « Etirement ».
class EtirementView extends StatelessWidget {
  /// {@macro etirement_view}
  const EtirementView({super.key});

  Future<void> _onRetourPresse(BuildContext context) async {
    final bloc = context.read<EtirementBloc>();
    final l10n = context.l10n;
    final enSeance = bloc.state.status != EtirementStatus.termine;
    if (!enSeance) {
      quitterEcranSeance(context);
      return;
    }
    final quitter = await showDialogueQuitterSeance(
      context,
      title: l10n.stretchExitDialogTitle,
      body: l10n.stretchExitDialogBody,
      confirmLabel: l10n.stretchExitDialogConfirm,
      cancelLabel: l10n.stretchExitDialogCancel,
    );
    if ((quitter ?? false) && context.mounted) {
      bloc.add(const EtirementMisEnPause());
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
        await _onRetourPresse(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundDeep,
        appBar: BarreOutils(
          title: l10n.stretchTitle,
          backLabel: l10n.stretchToolbarBack,
          onBack: () => _onRetourPresse(context),
          trailing: BoutonVoixOff(
            onLabel: l10n.stretchVoiceoverOnLabel,
            offLabel: l10n.stretchVoiceoverOffLabel,
          ),
        ),
        body: FondApplication(
          child: SafeArea(
            child: BlocConsumer<EtirementBloc, EtirementState>(
              listenWhen: (p, c) =>
                  p.segmentIndex != c.segmentIndex || p.status != c.status,
              listener: (context, state) {
                if (state.status == EtirementStatus.termine) {
                  unawaited(HapticFeedback.mediumImpact());
                } else if (state.status == EtirementStatus.enCours) {
                  unawaited(HapticFeedback.selectionClick());
                }
              },
              builder: (context, state) => switch (state.status) {
                EtirementStatus.preparation => EcranPreparation(
                  phrase: l10n.stretchCountdownPrepare,
                  compteur: state.prepRestant,
                ),
                EtirementStatus.enCours ||
                EtirementStatus.enPause => _LayoutEnCours(state: state),
                EtirementStatus.termine => _LayoutCelebration(state: state),
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

  final EtirementState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enPause = state.status == EtirementStatus.enPause;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone_android,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.stretchPhonePrompt,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context
                .read<EtirementBloc>()
                .add(const EtirementPauseBasculee()),
            child: _GuideEtirement(
              progress: state.segmentProgress,
              enPause: enPause,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.segment.label(l10n),
            style: const TextStyle(
              color: AppColors.successVert,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l10n.stretchTimeRange(
              formatTempsEtirement(state.segmentStart),
              formatTempsEtirement(state.segmentEnd),
            ),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(
                AppRadii.card,
              ),
            ),
            child: Text(
              state.segment.instruction(l10n),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text),
            ),
          ),
          const SizedBox(height: 16),
          _ListeSegments(vues: state.vuesSegments),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.stretchElapsed(
                  formatTempsEtirement(state.globalElapsed),
                ),
                style: const TextStyle(color: AppColors.textMuted),
              ),
              Text(
                l10n.stretchRemaining(
                  formatTempsEtirement(state.globalRemaining),
                ),
                style: const TextStyle(
                  color: AppColors.successVert,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (enPause) ...[
            const SizedBox(height: 8),
            Text(
              l10n.stretchResumeHint,
              style: const TextStyle(color: AppColors.accentGold),
            ),
          ],
          const Spacer(),
          IndicationAudio(label: l10n.stretchAudioHint),
          const SizedBox(height: 12),
          BoutonRecommencer(
            label: l10n.stretchRestart,
            icon: Icons.restart_alt,
            onTap: () => context
                .read<EtirementBloc>()
                .add(const EtirementRedemarree()),
          ),
        ],
      ),
    );
  }
}

class _GuideEtirement extends StatelessWidget {
  const _GuideEtirement({required this.progress, required this.enPause});

  final double progress;
  final bool enPause;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: _AnneauProgression(progress: progress),
          ),
          Icon(
            enPause ? Icons.pause : Icons.self_improvement,
            size: 48,
            color: AppColors.text,
          ),
        ],
      ),
    );
  }
}

/// Anneau de progression animé : interpole en douceur entre deux ticks du
/// bloc (le ticker émet par paliers de 200 ms, d'où des sauts sans animation).
///
/// `StatefulWidget` dédié (la page reste Stateless). Au changement de segment
/// (progression qui décroît), il se replace instantanément (pas de
/// rembobinage). Respecte `reduceMotion`.
class _AnneauProgression extends StatefulWidget {
  const _AnneauProgression({required this.progress});

  final double progress;

  @override
  State<_AnneauProgression> createState() => _AnneauProgressionState();
}

class _AnneauProgressionState extends State<_AnneauProgression> {
  double _precedent = 0;

  @override
  void initState() {
    super.initState();
    _precedent = widget.progress;
  }

  @override
  void didUpdateWidget(_AnneauProgression oldWidget) {
    super.didUpdateWidget(oldWidget);
    _precedent = oldWidget.progress;
  }

  @override
  Widget build(BuildContext context) {
    // Décroissance = nouveau segment : snap (pas d'animation arrière).
    final reset = widget.progress < _precedent;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _precedent, end: widget.progress),
      // Légèrement > au tick (200 ms) pour un remplissage continu.
      duration: (reset || reduceMotion)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      builder: (context, valeur, _) => CircularProgressIndicator(
        value: valeur,
        strokeWidth: 6,
        backgroundColor: AppColors.surface,
        valueColor: const AlwaysStoppedAnimation<Color>(
          AppColors.successVert,
        ),
      ),
    );
  }
}

class _ListeSegments extends StatelessWidget {
  const _ListeSegments({required this.vues});

  final List<VueSegmentEtirement> vues;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        for (final v in vues)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: switch (v.status) {
                      EtirementStatutSegment.fait => AppColors.primary,
                      EtirementStatutSegment.actif => AppColors.successVert,
                      EtirementStatutSegment.aVenir => AppColors.textMuted
                          .withValues(alpha: 0.3),
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _BarreProgression(
                      progress: v.progress,
                      couleur: v.status == EtirementStatutSegment.fait
                          ? AppColors.primary
                          : AppColors.successVert,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  etirementLabelPourCle(l10n, v.labelKey),
                  style: TextStyle(
                    color: v.status == EtirementStatutSegment.actif
                        ? AppColors.text
                        : AppColors.textMuted,
                    fontWeight: v.status == EtirementStatutSegment.actif
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Barre de progression animée d'un segment (même logique que
/// [_AnneauProgression] : interpolation fluide entre ticks 200 ms, snap au
/// reset, respect de `reduceMotion`). [couleur] varie selon le statut.
class _BarreProgression extends StatefulWidget {
  const _BarreProgression({required this.progress, required this.couleur});

  final double progress;
  final Color couleur;

  @override
  State<_BarreProgression> createState() => _BarreProgressionState();
}

class _BarreProgressionState extends State<_BarreProgression> {
  double _precedent = 0;

  @override
  void initState() {
    super.initState();
    _precedent = widget.progress;
  }

  @override
  void didUpdateWidget(_BarreProgression oldWidget) {
    super.didUpdateWidget(oldWidget);
    _precedent = oldWidget.progress;
  }

  @override
  Widget build(BuildContext context) {
    final reset = widget.progress < _precedent;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _precedent, end: widget.progress),
      duration: (reset || reduceMotion)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      builder: (context, valeur, _) => LinearProgressIndicator(
        value: valeur,
        minHeight: 4,
        backgroundColor: AppColors.surface.withValues(alpha: 0.5),
        valueColor: AlwaysStoppedAnimation<Color>(widget.couleur),
      ),
    );
  }
}

class _LayoutCelebration extends StatelessWidget {
  const _LayoutCelebration({required this.state});

  final EtirementState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MiseEnPageCelebration(
      title: l10n.stretchCelebrationTitle,
      body: l10n.stretchCelebrationBody,
      actions: [
        BoutonRecommencer(
          label: l10n.stretchRestart,
          icon: Icons.restart_alt,
          onTap: () => context
              .read<EtirementBloc>()
              .add(const EtirementRedemarree()),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => quitterEcranSeance(context),
          child: Text(l10n.stretchCelebrationDone),
        ),
      ],
    );
  }
}
