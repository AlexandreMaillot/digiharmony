import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/formatage_duree.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Ligne de répartition d'une app : nom + durée + barre de proportion.
///
/// Présentation **factuelle et sobre** (DEC-TE-09) : pas de classement
/// « pire app », pas de couleur d'alerte. Barre en `AppColors.primary`
/// (chrome), jamais une couleur d'émotion (`MoodColors` interdit).
class LigneApp extends StatelessWidget {
  /// Crée une ligne d'app.
  const LigneApp({
    required this.nom,
    required this.duree,
    required this.fraction,
    super.key,
  });

  /// Nom lisible de l'app (ou « Autres » pour le bucket).
  final String nom;

  /// Durée d'usage.
  final Duration duree;

  /// Part du total (0..1) — largeur de la barre.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dureeTexte = formaterDuree(l10n, duree);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Semantics(
        label: l10n.tempsEcranAppSemantique(nom, dureeTexte),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nom,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  dureeTexte,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
