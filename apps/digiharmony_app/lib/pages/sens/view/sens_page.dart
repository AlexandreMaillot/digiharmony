// Les imports sens/donnees et sens/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'dart:async';
import 'dart:math' as math;

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/bien_etre_partage/dialogue_quitter_seance.dart';
import 'package:digiharmony_app/bien_etre_partage/ecran_preparation.dart';
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
    // Lu ici (dans build) et non dans `create` : depend du contexte.
    final langue = Localizations.localeOf(context).languageCode;
    return BlocProvider<SensBloc>(
      create: (context) => SensBloc(
        exercise: ExerciceAncrage.cinqQuatreTroisDeuxUn,
        enregistrerSeance: EnregistrerSeanceBienEtreUseCase(
          depot: context.read<DepotStatsBienEtre>(),
        ),
        gererAudio: GererAudioSensUseCase(
          depot: DepotAudioSensImpl(langue: langue),
        ),
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
          fermer: true,
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
                SensStatus.preparation => EcranPreparation(
                  phrase: context.l10n.sensesCountdownPrepare,
                  compteur: state.prepRestant,
                  couleur: AppColors.sensesAccentOr,
                ),
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
          _IndicateurEtapeAnime(
            current: state.stepIndex,
            total: state.exercise.totalSteps,
          ),
          const Spacer(),
          _IconeSensAnimee(sens: step.sense),
          const SizedBox(height: 16),
          _NumeroEtapeAnime(valeur: l10n.sensesCountValue(step.count)),
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
                  flex: 2,
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
                flex: 3,
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

/// Indicateur d'etapes anime : la pastille active grossit en douceur
/// (AnimatedContainer) et rebondit comme une goutte a chaque changement.
///
/// `StatefulWidget` dedie : la page parente reste Stateless ; l'animation
/// est declenchee par le changement de [current] via `didUpdateWidget`.
class _IndicateurEtapeAnime extends StatefulWidget {
  const _IndicateurEtapeAnime({required this.current, required this.total});

  final int current;
  final int total;

  @override
  State<_IndicateurEtapeAnime> createState() => _IndicateurEtapeAnimeState();
}

class _IndicateurEtapeAnimeState extends State<_IndicateurEtapeAnime>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void didUpdateWidget(_IndicateurEtapeAnime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current && !_reduceMotion) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.sensesStepProgress(
        widget.current + 1,
        widget.total,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.total; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _point(i),
            ),
        ],
      ),
    );
  }

  Widget _point(int i) {
    final actif = i == widget.current;
    // Largeur/couleur en transition douce a chaque rebuild.
    final dot = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: actif ? 28 : 10,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: i < widget.current
            ? AppColors.primary.withValues(alpha: 0.55)
            : actif
            ? AppColors.sensesAccentOr
            : AppColors.textMuted.withValues(alpha: 0.2),
      ),
    );
    if (!actif || _reduceMotion) return dot;
    // Pastille active : squish elastique « goutte d'eau » qui rebondit.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final pulse = math.sin(t * math.pi) * (1 - t);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
            1 - 0.25 * pulse,
            1 + 0.6 * pulse,
            1,
          ),
          child: child,
        );
      },
      child: dot,
    );
  }
}

/// Icone centrale animee : le nouveau glyphe « pop » a chaque changement de
/// sens (scale elastique + fondu + leger pivot). Cercle statique autour.
class _IconeSensAnimee extends StatefulWidget {
  const _IconeSensAnimee({required this.sens});

  final SensAncrage sens;

  @override
  State<_IconeSensAnimee> createState() => _IconeSensAnimeeState();
}

class _IconeSensAnimeeState extends State<_IconeSensAnimee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_IconeSensAnimee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sens != widget.sens && !_reduceMotion) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icone = Icon(widget.sens.icon, color: AppColors.primary, size: 36);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.27)),
      ),
      child: Center(
        child: _reduceMotion
            ? icone
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = Curves.easeOut.transform(_controller.value);
                  final pop = Curves.elasticOut.transform(_controller.value);
                  final scale = 0.5 + 0.5 * pop;
                  return Opacity(
                    opacity: t,
                    child: Transform.rotate(
                      angle: (1 - t) * -0.4,
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
                child: icone,
              ),
      ),
    );
  }
}

/// Numero d'etape anime : flip « cube » 3D — l'ancien chiffre bascule et le
/// nouveau apparait de face a chaque changement de [valeur].
class _NumeroEtapeAnime extends StatefulWidget {
  const _NumeroEtapeAnime({required this.valeur});

  final String valeur;

  @override
  State<_NumeroEtapeAnime> createState() => _NumeroEtapeAnimeState();
}

class _NumeroEtapeAnimeState extends State<_NumeroEtapeAnime>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late String _ancien;
  late String _courant;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    _ancien = widget.valeur;
    _courant = widget.valeur;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(_NumeroEtapeAnime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valeur != widget.valeur) {
      _ancien = oldWidget.valeur;
      _courant = widget.valeur;
      if (_reduceMotion) {
        _controller.value = 1;
      } else {
        unawaited(_controller.forward(from: 0));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _chiffre(String s) => Text(
    s,
    style: const TextStyle(
      color: AppColors.sensesAccentOr,
      fontSize: 72,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) return _chiffre(_courant);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final premiereMoitie = t < 0.5;
        final angle = premiereMoitie
            ? (math.pi / 2) * Curves.easeIn.transform(t * 2)
            : -(math.pi / 2) * (1 - Curves.easeOut.transform((t - 0.5) * 2));
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(angle),
          child: _chiffre(premiereMoitie ? _ancien : _courant),
        );
      },
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
