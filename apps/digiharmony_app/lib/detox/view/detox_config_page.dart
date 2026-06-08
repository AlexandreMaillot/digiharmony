import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/detox/bloc/detox_config_bloc.dart';
import 'package:digiharmony_app/detox/detox_l10n.dart';
import 'package:digiharmony_app/detox/routes_detox.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:digiharmony_app/widgets/barre_outils.dart';
import 'package:digiharmony_app/widgets/fond_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ecran de configuration Detox (ambiance + duree).
class DetoxConfigPage extends StatelessWidget {
  /// {@macro detox_config_page}
  const DetoxConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetoxConfigBloc>(
      create: (_) => DetoxConfigBloc(),
      child: const DetoxConfigView(),
    );
  }
}

/// UI de la configuration Detox.
class DetoxConfigView extends StatelessWidget {
  /// {@macro detox_config_view}
  const DetoxConfigView({super.key});

  Future<void> _onStart(BuildContext context) async {
    await HapticFeedback.selectionClick();
    if (!context.mounted) return;
    final s = context.read<DetoxConfigBloc>().state;
    await Navigator.of(context).push(
      RoutesDetox.lecteur(
        ambianceId: s.ambianceId,
        durationMinutes: s.durationMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ThemeApplication.bubbleBackground,
      appBar: BarreOutils(
        title: l10n.detoxTitle,
        backLabel: l10n.detoxToolbarBack,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: FondApplication(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.detoxSetupHeading,
                  style: const TextStyle(
                    color: ThemeApplication.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.detoxSetupSubtitle,
                  style: const TextStyle(color: ThemeApplication.muted),
                ),
                const SizedBox(height: 24),
                _SectionLabel(l10n.detoxSectionAmbiance),
                const SizedBox(height: 12),
                BlocSelector<
                  DetoxConfigBloc,
                  DetoxConfigEtat,
                  IdAmbianceDetox>(
                  selector: (s) => s.ambianceId,
                  builder: (context, selected) => GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      for (final a in AmbianceDetox.all)
                        _CarteAmbiance(
                          ambiance: a,
                          selected: a.id == selected,
                          onTap: () {
                            unawaited(HapticFeedback.selectionClick());
                            context
                                .read<DetoxConfigBloc>()
                                .add(DetoxAmbianceSelectionnee(a.id));
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(l10n.detoxSectionDuration),
                const SizedBox(height: 12),
                BlocSelector<DetoxConfigBloc, DetoxConfigEtat, int>(
                  selector: (s) => s.durationMinutes,
                  builder: (context, selected) => Row(
                    children: [
                      for (final d in DureeDetox.all)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _PuceDuree(
                              duration: d,
                              selected: d.minutes == selected,
                              onTap: () {
                                unawaited(HapticFeedback.selectionClick());
                                context
                                    .read<DetoxConfigBloc>()
                                    .add(DetoxDureeSelectionnee(d.minutes));
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<DetoxConfigBloc, DetoxConfigEtat>(
                  builder: (context, s) => _PuceRecap(
                    label: s.ambianceId.ambianceLabel(l10n),
                    minutes: s.durationMinutes,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: ThemeApplication.primary,
                    foregroundColor: ThemeApplication.bubbleBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _onStart(context),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.detoxStart),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: ThemeApplication.muted,
        fontSize: 12,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CarteAmbiance extends StatelessWidget {
  const _CarteAmbiance({
    required this.ambiance,
    required this.selected,
    required this.onTap,
  });

  final AmbianceDetox ambiance;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeApplication.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeApplication.surface
                .withValues(alpha: selected ? 0.7 : 0.35),
            borderRadius: BorderRadius.circular(ThemeApplication.radiusMedium),
            border: Border.all(
              color: selected ? ambiance.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(ambiance.icon, color: ambiance.color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ambiance.id.ambianceLabel(l10n),
                      style: const TextStyle(
                        color: ThemeApplication.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ambiance.id.ambianceDescription(l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ThemeApplication.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: ambiance.color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PuceDuree extends StatelessWidget {
  const _PuceDuree({
    required this.duration,
    required this.selected,
    required this.onTap,
  });

  final DureeDetox duration;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeApplication.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? ThemeApplication.primary
              : ThemeApplication.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(ThemeApplication.radiusMedium),
        ),
        child: Column(
          children: [
            Text(
              l10n.detoxDurationMinutes(duration.minutes),
              style: TextStyle(
                color: selected
                    ? ThemeApplication.bubbleBackground
                    : ThemeApplication.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (duration.isDefault)
              Text(
                l10n.detoxDurationDefaultBadge,
                style: TextStyle(
                  color: selected
                      ? ThemeApplication.bubbleBackground
                      : ThemeApplication.muted,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PuceRecap extends StatelessWidget {
  const _PuceRecap({required this.label, required this.minutes});

  final String label;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeApplication.surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.volume_up,
              size: 16,
              color: ThemeApplication.primary,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.detoxRecap(label, minutes),
              style: const TextStyle(color: ThemeApplication.foreground),
            ),
          ],
        ),
      ),
    );
  }
}
