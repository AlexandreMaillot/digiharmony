import 'dart:async';

import 'package:digiharmony_app/config/legal_urls.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Section projet — lien open source (GitHub) + mention Erasmus+.
///
/// Le lien digiharmony.org est masqué (V1 — pas de lien mort,
/// décision 2026-06-06). Ouverture URL via url_launcher (DEC-PARAM-05).
class SectionProjet extends StatelessWidget {
  /// Crée la section projet.
  const SectionProjet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.parametresSectionProjet,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Lien open source — GitHub
        _LienProjet(
          icone: Icons.code,
          titre: l10n.parametresOpenSourceTitre,
          sousTitre: l10n.parametresOpenSourceSousTitre,
          onTap: () => unawaited(_ouvrirUrl(context, LegalUrls.github)),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Carte Erasmus+ avec logo officiel bundlé
        _CarteErasmus(texte: l10n.parametresErasmusCorps),
      ],
    );
  }

  Future<void> _ouvrirUrl(BuildContext context, String url) async {
    // HapticFeedback est fire-and-forget (DEC-PARAM-05).
    unawaited(HapticFeedback.selectionClick());
    final uri = Uri.parse(url);
    // On NE gate PAS sur canLaunchUrl : sur Android 11+ il renvoie false
    // (« component name is null ») meme quand launchUrl reussit. On tente
    // l'ouverture directe et on ne signale l'echec que si launchUrl jette
    // ou renvoie false. (DEC-PARAM-05)
    var succes = true;
    try {
      succes = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      succes = false;
    } on Exception {
      succes = false;
    }
    if (!succes && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.parametresLienIndisponible),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Ligne projet tappable (open source, lien externe).
class _LienProjet extends StatelessWidget {
  const _LienProjet({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final IconData icone;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.cardRadius,
      child: InkWell(
        borderRadius: AppRadii.cardRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icone, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      sousTitre,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.open_in_new,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de mention Erasmus+ avec le logo officiel bundlé.
class _CarteErasmus extends StatelessWidget {
  const _CarteErasmus({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo_eu_funding.png',
            height: 40,
            errorBuilder: (ctx, e, st) =>
                const SizedBox(width: 40, height: 40),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              texte,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
