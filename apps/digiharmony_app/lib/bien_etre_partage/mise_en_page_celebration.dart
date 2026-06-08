import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Layout de celebration generique partage par les exercices.
///
/// Affiche un burst (coupe si `reduceMotion`), un titre, un corps et les
/// actions fournies (ex. Recommencer / Termine).
class MiseEnPageCelebration extends StatelessWidget {
  /// {@macro mise_en_page_celebration}
  const MiseEnPageCelebration({
    required this.title,
    required this.body,
    required this.actions,
    this.icon = Icons.celebration_outlined,
    super.key,
  });

  /// Titre de felicitation.
  final String title;

  /// Message apaisant.
  final String body;

  /// Boutons d'action (Recommencer, Termine, ...).
  final List<Widget> actions;

  /// Icone du burst.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final burst = Icon(icon, size: 72, color: AppColors.successVert);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (reduceMotion)
              burst
            else
              burst
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                  ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),
            ...actions,
          ],
        ),
      ),
    );
  }
}
