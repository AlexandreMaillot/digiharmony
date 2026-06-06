import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Hint de navigation « ‹ précédent | suivant › » en bas du deck.
///
/// Très atténué (textMuted @45%). Masqué si `disableAnimations` est vrai
/// (reduced-motion — DEC-CO-08) pour éviter la redondance avec le hint
/// visuel du peek.
class HintSwipe extends StatelessWidget {
  /// Crée le hint de swipe.
  const HintSwipe({this.visible = true, super.key});

  /// Si faux, le widget est invisible (reduced-motion ou carte unique).
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        '‹ ${l10n.conseilsHintPrecedent}  |  ${l10n.conseilsHintSuivant} ›',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textMuted.withValues(alpha: 0.45),
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
