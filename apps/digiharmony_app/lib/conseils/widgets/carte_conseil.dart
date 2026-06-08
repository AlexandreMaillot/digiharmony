import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/conseils/conseils_l10n.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:flutter/material.dart';

/// Carte d'un conseil par emotion : barre d'accent, label emotion, titre,
/// section « a faire », section « a eviter », CTA respiration.
class CarteConseil extends StatelessWidget {
  /// {@macro carte_conseil}
  const CarteConseil({
    required this.conseil,
    required this.onTryBreathing,
    super.key,
  });

  /// Donnee du conseil (catalogue statique).
  final ConseilEmotion conseil;

  /// Action « Essayer la respiration ».
  final VoidCallback onTryBreathing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThemeApplication.surface,
        borderRadius: BorderRadius.circular(ThemeApplication.radiusLarge),
        border: Border.all(color: conseil.color.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeApplication.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 4, color: conseil.color),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: conseil.color, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.adviceEmotionLabel.toUpperCase(),
                          style: TextStyle(
                            color: conseil.color,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.conseilTexte(conseil.titleKey),
                      style: const TextStyle(
                        color: ThemeApplication.foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(l10n.adviceDoSectionLabel),
                    const SizedBox(height: 8),
                    for (final key in conseil.doKeys)
                      _ListItem(
                        text: l10n.conseilTexte(key),
                        icon: Icons.check,
                        accent: conseil.color,
                      ),
                    const SizedBox(height: 16),
                    _SectionLabel(l10n.adviceAvoidSectionLabel),
                    const SizedBox(height: 8),
                    for (final key in conseil.avoidKeys)
                      _ListItem(
                        text: l10n.conseilTexte(key),
                        icon: Icons.close,
                        accent: ThemeApplication.muted,
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onTryBreathing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: conseil.color,
                          foregroundColor: ThemeApplication.bubbleBackground,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeApplication.radiusSmall,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.air),
                        label: Text(l10n.adviceTryBreathing),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: ThemeApplication.muted,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        fontSize: 12,
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.text,
    required this.icon,
    required this.accent,
  });

  final String text;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ThemeApplication.foreground,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
