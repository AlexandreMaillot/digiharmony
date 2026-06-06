import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Vue d'état générique : icône douce + message (+ aide + action facultatives).
///
/// Factorise vide / indisponible / erreur (§5.4–5.7). Ton bienveillant,
/// jamais alarmant (public mineur).
class VueEtatMessage extends StatelessWidget {
  /// Crée une vue d'état message.
  const VueEtatMessage({
    required this.icone,
    required this.message,
    this.aide,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Icône illustrative.
  final IconData icone;

  /// Message principal.
  final String message;

  /// Texte d'aide secondaire (facultatif).
  final String? aide;

  /// Libellé de l'action (facultatif, ex. « Réessayer »).
  final String? actionLabel;

  /// Callback de l'action (facultatif).
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icone, size: 48, color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        if (aide != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            aide!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}
