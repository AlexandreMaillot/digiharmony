import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:flutter/material.dart';

/// Controles prev | separateur | next sous la carte.
///
/// « precedent » est desactive sur la 1re carte, « suivant » sur la derniere.
class ControlesCarrousel extends StatelessWidget {
  /// {@macro controles_carrousel}
  const ControlesCarrousel({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
    super.key,
  });

  /// Index courant.
  final int index;

  /// Nombre total de cartes.
  final int total;

  /// Aller a la carte precedente.
  final VoidCallback onPrev;

  /// Aller a la carte suivante.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canPrev = index > 0;
    final canNext = index < total - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavButton(
          icon: Icons.chevron_left,
          label: l10n.advicePrev,
          onPressed: canPrev ? onPrev : null,
        ),
        Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: ThemeApplication.muted.withValues(alpha: 0.4),
        ),
        _NavButton(
          icon: Icons.chevron_right,
          label: l10n.adviceNext,
          onPressed: canNext ? onNext : null,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? ThemeApplication.foreground
        : ThemeApplication.muted.withValues(alpha: 0.4);
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: color),
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}
