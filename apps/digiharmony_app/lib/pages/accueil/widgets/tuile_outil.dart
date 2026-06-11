import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Tuile carrée d'outil (grille 2 colonnes).
///
/// Le haptique est délégué au [onTap] appelant (ex. via `ouvrirPlaceholder`).
class TuileOutil extends StatelessWidget {
  /// Crée une tuile outil.
  const TuileOutil({
    required this.label,
    required this.icone,
    required this.onTap,
    this.description,
    this.accent = AppColors.primary,
    super.key,
  });

  /// Libellé principal de la tuile.
  final String label;

  /// Icône Material.
  final IconData icone;

  /// Callback au tap (le haptique est géré par l'appelant, ex.
  /// `ouvrirPlaceholder`).
  final VoidCallback onTap;

  /// Description optionnelle (ex. texte du conseil du jour).
  final String? description;

  /// Couleur d'accent de la tuile (dégradé, icône, libellé, bordure).
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.cardRadius,
        child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                accent.withValues(alpha: 0.42),
                AppColors.surfaceBright,
              ),
              AppColors.surfaceBright,
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.55)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Chip d'icône colorée.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.28),
                      borderRadius: AppRadii.buttonRadius,
                    ),
                    child: Icon(icone, color: accent, size: 24),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                      color: accent,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
