// Les imports detox/donnees et detox/domaine déclenchent un faux positif
// directives_ordering (deux sous-sections reconnues malgré le tri).
// ignore_for_file: directives_ordering
import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/bien_etre_partage/dialogue_quitter_seance.dart';
import 'package:digiharmony_app/bien_etre_partage/mise_en_page_celebration.dart';
import 'package:digiharmony_app/bien_etre_partage/quitter_seance.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/pages/detox/args_detox_lecteur.dart';
import 'package:digiharmony_app/pages/detox/bloc/detox_lecteur_bloc.dart';
import 'package:digiharmony_app/pages/detox/detox_l10n.dart';
import 'package:digiharmony_app/pages/detox/donnees/depot_audio_detox.dart';
import 'package:digiharmony_app/pages/detox/domaine/usecase/usecase.dart';
import 'package:digiharmony_app/pages/detox/format_duree_detox.dart';
import 'package:digiharmony_app/pages/detox/widgets/fleur_detox_animee.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/widgets/barre_outils.dart';
import 'package:digiharmony_app/widgets/fond_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lecteur Detox « Ta pause » — Page stateless.
///
/// Construit les UseCases (depuis les dépôts accessibles via context) et les
/// injecte dans [DetoxLecteurBloc]. Aucune logique métier ici.
class DetoxLecteurPage extends StatelessWidget {
  /// {@macro detox_lecteur_page}
  const DetoxLecteurPage({required this.args, super.key});

  /// Parametres recus de la configuration.
  final ArgsDetoxLecteur args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statsDepot = context.read<DepotStatsBienEtre>();
    return BlocProvider<DetoxLecteurBloc>(
      create: (_) => DetoxLecteurBloc(
        session: SeanceDetox(
          ambianceId: args.ambianceId,
          total: Duration(minutes: args.durationMinutes),
        ),
        audioUseCase: GererAudioDetoxUseCase(
          depot: DepotAudioDetoxImpl(),
        ),
        enregistrerSeanceUseCase: EnregistrerSeanceBienEtreUseCase(
          depot: statsDepot,
        ),
        mediaTitle: l10n.detoxPlayerMediaTitle,
      )..add(const DetoxLecteurDemarre()),
      child: DetoxLecteurView(ambianceId: args.ambianceId),
    );
  }
}

/// UI du lecteur Detox — View stateless.
class DetoxLecteurView extends StatelessWidget {
  /// {@macro detox_lecteur_view}
  const DetoxLecteurView({required this.ambianceId, super.key});

  /// Ambiance en cours (badge).
  final IdAmbianceDetox ambianceId;

  Future<void> _onSortieRequise(BuildContext context) async {
    final bloc = context.read<DetoxLecteurBloc>();
    final l10n = context.l10n;
    if (bloc.state.status == DetoxLecteurStatus.termine) {
      quitterEcranSeance(context);
      return;
    }
    await HapticFeedback.selectionClick();
    if (!context.mounted) return;
    final quitter = await showDialogueQuitterSeance(
      context,
      title: l10n.detoxPlayerEndConfirmTitle,
      body: l10n.detoxPlayerEndConfirmBody,
      confirmLabel: l10n.detoxPlayerEndConfirmConfirm,
      cancelLabel: l10n.detoxPlayerEndConfirmCancel,
    );
    if ((quitter ?? false) && context.mounted) {
      bloc.add(const DetoxLecteurTermine());
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
        await _onSortieRequise(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundDeep,
        appBar: BarreOutils(
          title: l10n.detoxPlayerTitle,
          backLabel: l10n.detoxPlayerToolbarBack,
          fermer: true,
          onBack: () => _onSortieRequise(context),
          trailing: _BadgeAmbiance(ambianceId: ambianceId),
        ),
        body: FondApplication(
          child: SafeArea(
            child: BlocConsumer<DetoxLecteurBloc, DetoxLecteurState>(
              listenWhen: (p, c) => p.status != c.status,
              listener: (context, state) {
                if (state.status == DetoxLecteurStatus.termine) {
                  unawaited(HapticFeedback.lightImpact());
                }
              },
              builder: (context, state) => switch (state.status) {
                DetoxLecteurStatus.enLecture => _LayoutEnLecture(
                  state: state,
                  onEnd: () => _onSortieRequise(context),
                ),
                DetoxLecteurStatus.termine =>
                  _LayoutCelebration(state: state),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeAmbiance extends StatelessWidget {
  const _BadgeAmbiance({required this.ambianceId});

  final IdAmbianceDetox ambianceId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: MoodColors.calm.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ambianceId.ambianceIcon,
              size: 16,
              color: MoodColors.calm,
            ),
            const SizedBox(width: 6),
            Text(
              ambianceId.ambianceLabel(l10n),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutEnLecture extends StatelessWidget {
  const _LayoutEnLecture({required this.state, required this.onEnd});

  final DetoxLecteurState state;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          FleurDetoxAnimee(
            progress: state.progress,
            bloomProgress: state.bloomProgress,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.detoxPlayerBloomTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.detoxPlayerBloomSubtitle,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const Spacer(),
          Text(
            l10n.detoxPlayerTimeRemaining(
              formatDureeDetox(state.remaining),
            ),
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.detoxPlayerTotalTime(formatDureeDetox(state.total)),
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _CarteTipAvion(label: l10n.detoxPlayerAirplaneTip),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onEnd,
            child: Text(l10n.detoxPlayerEnd),
          ),
        ],
      ),
    );
  }
}

class _CarteTipAvion extends StatelessWidget {
  const _CarteTipAvion({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flight, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutCelebration extends StatelessWidget {
  const _LayoutCelebration({required this.state});

  final DetoxLecteurState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MiseEnPageCelebration(
      icon: Icons.spa_outlined,
      title: l10n.detoxPlayerCelebrationTitle,
      body: l10n.detoxPlayerCelebrationBody,
      actions: [
        FilledButton(
          onPressed: () => quitterEcranSeance(context),
          child: Text(l10n.detoxPlayerCelebrationDone),
        ),
      ],
    );
  }
}
