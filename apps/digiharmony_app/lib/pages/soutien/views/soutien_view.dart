import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Vue principale de l'écran de soutien.
///
/// Stub M4 — UI complète livrée en M6.
class SoutienView extends StatelessWidget {
  /// Crée la vue de soutien.
  const SoutienView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDeep,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      // TODO(M6): UI complète SoutienView
      body: const SizedBox.shrink(),
    );
  }
}
