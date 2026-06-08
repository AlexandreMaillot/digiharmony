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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icone, color: AppColors.primary, size: 28),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 14,
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
    );
  }
}
