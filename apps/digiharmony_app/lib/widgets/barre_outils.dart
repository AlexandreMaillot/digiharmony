import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// AppBar custom partagee : bouton retour (chevron) + titre centre + trailing.
///
/// - `showMenu` : reserve un espace a droite (equilibre visuel) quand il n'y a
///   pas de `trailing`.
/// - `trailing` : widget optionnel a droite (ex. bouton volume voix off).
class BarreOutils extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro barre_outils}
  const BarreOutils({
    this.title,
    this.onBack,
    this.trailing,
    this.showMenu = false,
    this.backLabel,
    super.key,
  });

  /// Titre centre (resolu depuis l'ARB par l'appelant).
  final String? title;

  /// Callback du bouton retour. Si null, pas de bouton retour.
  final VoidCallback? onBack;

  /// Widget optionnel a droite (ex. bouton volume).
  final Widget? trailing;

  /// Reserve un espace a droite si aucun `trailing` n'est fourni.
  final bool showMenu;

  /// Label d'accessibilite du bouton retour.
  final String? backLabel;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final leading = onBack == null
        ? const SizedBox(width: 48)
        : IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.text,
            tooltip: backLabel,
            onPressed: onBack,
          );

    final right = trailing ?? (showMenu ? null : const SizedBox(width: 48));

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            leading,
            Expanded(
              child: Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            right ?? const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
