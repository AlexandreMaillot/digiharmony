import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:flutter/material.dart';

/// Pastille informative « guide audio / voix off disponible ».
class IndicationAudio extends StatelessWidget {
  /// {@macro indication_audio}
  const IndicationAudio({
    required this.label,
    this.icon = Icons.music_note_outlined,
    super.key,
  });

  /// Texte affiche (resolu depuis l'ARB).
  final String label;

  /// Icone d'entete.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeApplication.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ThemeApplication.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: ThemeApplication.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: ThemeApplication.muted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
