import 'dart:async';
import 'dart:math' as math;

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/formatage_duree.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/section_actions_temps_ecran.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Vue nominale : jauge circulaire + semaine + confidentialité + actions.
///
/// Présentation **neutre, non culpabilisante** (DEC-TE-09). Les top-apps ne
/// sont plus affichées (réalignement maquette Banani new_screen11).
class VueResume extends StatelessWidget {
  /// Crée la vue résumé.
  const VueResume({
    required this.resume,
    required this.historique,
    super.key,
  });

  /// Données agrégées à afficher.
  final ResumeTempsEcran resume;

  /// Historique des 7 derniers jours (toujours 7 entrées).
  final List<EntreeHistorique> historique;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    // Total semaine : somme des 7 jours de l'historique.
    final totalSemaine = historique.fold<Duration>(
      Duration.zero,
      (acc, e) => acc + e.total,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Intro.
          Text(
            l10n.tempsEcranIntro,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Jauge circulaire + total du jour au centre.
          Center(
            child: _JaugeCirculaire(total: resume.total),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Ligne semaine : total à gauche, graphe 7 jours à droite.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Total semaine.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formaterDuree(l10n, totalSemaine),
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    l10n.tempsEcranCetteSemaine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),

              // Mini-graphe 7 jours (remplit l'espace restant).
              Expanded(
                child: _GrapheSeptJours(
                  historique: historique,
                  locale: locale,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Carte confidentialité (données locales jamais envoyées).
          CarteConfidentialiteTempsEcran(
            message: l10n.tempsEcranDonneesLocales,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section « Et maintenant ? » + cartes d'action (widget partagé iOS).
          const SectionActionsTempsEcran(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Jauge circulaire
// ─────────────────────────────────────────────────────────────────────────────

/// Fraction de remplissage de la jauge (0..1), plafonnée à 1.
///
/// La jauge est **neutre/informative** : 8 h = plein, pas d'objectif ni
/// de couleur d'alerte. Jamais culpabilisante (DEC-TE-09).
double _fractionJauge(Duration total) {
  const plafond = Duration(hours: 8);
  if (plafond.inSeconds == 0) return 0;
  return (total.inSeconds / plafond.inSeconds).clamp(0.0, 1.0);
}

class _JaugeCirculaire extends StatelessWidget {
  const _JaugeCirculaire({required this.total});

  final Duration total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    final fraction = _fractionJauge(total);

    return Semantics(
      label: formaterDuree(l10n, total),
      child: SizedBox(
        width: 220,
        height: 220,
        child: reducedMotion
            ? CustomPaint(
                painter: _JaugePainter(fraction: fraction),
                child: _CentreJauge(total: total),
              )
            : _JaugeAnimee(fraction: fraction, total: total),
      ),
    );
  }
}

/// Animation de remplissage de la jauge.
class _JaugeAnimee extends StatefulWidget {
  const _JaugeAnimee({required this.fraction, required this.total});

  final double fraction;
  final Duration total;

  @override
  State<_JaugeAnimee> createState() => _JaugeAnimeeState();
}

class _JaugeAnimeeState extends State<_JaugeAnimee>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)
        .drive(Tween<double>(begin: 0, end: widget.fraction));
    unawaited(_ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => CustomPaint(
        painter: _JaugePainter(fraction: _anim.value),
        child: _CentreJauge(total: widget.total),
      ),
    );
  }
}

/// Painter de l'anneau de progression dégradé cyan → vert.
class _JaugePainter extends CustomPainter {
  const _JaugePainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 12;
    const epaisseur = 16.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Fond de l'anneau (atténué).
    final paintFond = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), radius, paintFond);

    if (fraction <= 0) return;

    // Arc dégradé cyan → vert (primaryLight → vertAppel).
    final sweep = 2 * math.pi * fraction;
    const startAngle = -math.pi / 2; // 12 h

    final shader = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweep,
      colors: const [
        AppColors.primaryLight,
        AppColors.primary,
        AppColors.vertAppel,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    final paintArc = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweep, false, paintArc);
  }

  @override
  bool shouldRepaint(_JaugePainter old) => old.fraction != fraction;
}

/// Contenu centré à l'intérieur de la jauge : durée + label.
class _CentreJauge extends StatelessWidget {
  const _CentreJauge({required this.total});

  final Duration total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formaterDuree(l10n, total),
            style: theme.textTheme.headlineMedium,
          ),
          Text(
            l10n.tempsEcranAujourdhui,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini-graphe 7 jours
// ─────────────────────────────────────────────────────────────────────────────

class _GrapheSeptJours extends StatelessWidget {
  const _GrapheSeptJours({
    required this.historique,
    required this.locale,
  });

  final List<EntreeHistorique> historique;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (historique.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final aujourdhui = DateTime(now.year, now.month, now.day);

    // Hauteur max des barres en pixels.
    const hauteurMax = 48.0;
    const hauteurMin = 4.0;

    final maxSecondes = historique
        .map((e) => e.total.inSeconds)
        .fold<int>(0, math.max);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final entree in historique)
          _ColonneJour(
            entree: entree,
            estAujourdhui: entree.jour == aujourdhui,
            hauteur: maxSecondes == 0
                ? hauteurMin
                : (entree.total.inSeconds / maxSecondes * hauteurMax)
                    .clamp(hauteurMin, hauteurMax),
            locale: locale,
          ),
      ],
    );
  }
}

class _ColonneJour extends StatelessWidget {
  const _ColonneJour({
    required this.entree,
    required this.estAujourdhui,
    required this.hauteur,
    required this.locale,
  });

  final EntreeHistorique entree;
  final bool estAujourdhui;
  final double hauteur;
  final String locale;

  @override
  Widget build(BuildContext context) {
    // Étiquette de jour via DateFormat.EEEEE (1 lettre, locale-aware).
    final labelJour = DateFormat.EEEEE(locale).format(entree.jour);

    final couleurBarre = estAujourdhui
        ? AppColors.primary
        : AppColors.primaryLight.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre.
        Container(
          width: 16,
          height: hauteur,
          decoration: BoxDecoration(
            color: couleurBarre,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        // Étiquette (1 lettre, locale-aware).
        Text(
          labelJour,
          style: TextStyle(
            fontSize: 10,
            color: estAujourdhui ? AppColors.primary : AppColors.textMuted,
            fontWeight:
                estAujourdhui ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
