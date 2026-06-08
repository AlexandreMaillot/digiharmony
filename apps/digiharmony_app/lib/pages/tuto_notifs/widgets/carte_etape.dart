import 'package:digiharmony_app/pages/tuto_notifs/modeles/etape_tuto_modele.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte d'une étape numérotée du tutoriel.
///
/// Badge n° cercle cyan (`AppColors.primary` alpha 0.18 + bord) + icône +
/// titre gras + description atténuée. Fond `AppColors.surface`, rayon 12.
class CarteEtape extends StatelessWidget {
  /// Crée une carte d'étape.
  const CarteEtape({
    required this.numero,
    required this.etape,
    super.key,
  });

  /// Numéro affiché dans la pastille (1-indexé).
  final int numero;

  /// Contenu de l'étape.
  final EtapeTutoModele etape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${etape.titre}. ${etape.corps}',
      container: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadii.button),
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge numéro.
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '$numero',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Icône de l'étape.
            Icon(etape.icone, color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            // Titre + description.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etape.titre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    etape.corps,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
