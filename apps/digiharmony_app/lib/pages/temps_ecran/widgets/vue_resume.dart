import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/formatage_duree.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/ligne_app.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Vue nominale : total du jour + message bienveillant + répartition top apps.
///
/// Présentation **neutre, non culpabilisante** (DEC-TE-09).
class VueResume extends StatelessWidget {
  /// Crée la vue résumé.
  const VueResume({required this.resume, super.key});

  /// Données agrégées à afficher.
  final ResumeTempsEcran resume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête : « Aujourd'hui » + total formaté.
        Text(
          l10n.tempsEcranTotalAujourdhui,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          formaterDuree(l10n, resume.total),
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        // Message bienveillant.
        Text(
          l10n.tempsEcranMessageBienveillant,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Répartition par app.
        Text(
          l10n.tempsEcranTopApps,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final app in resume.topApps)
          LigneApp(
            nom: app.nomApp,
            duree: app.duree,
            fraction: app.fractionDuTotal,
          ),
        if (resume.autres > Duration.zero)
          LigneApp(
            nom: l10n.tempsEcranAppAutres,
            duree: resume.autres,
            fraction: resume.total.inSeconds == 0
                ? 0
                : resume.autres.inSeconds / resume.total.inSeconds,
          ),
      ],
    );
  }
}
