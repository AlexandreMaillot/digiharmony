import 'dart:async';

import 'package:digiharmony_app/config/legal_urls.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Section de confidentialité — carte rassurante zéro-collecte + liens légaux.
///
/// Public mineur. Ton bienveillant (DEC-003). Pas de compte, pas de
/// collecte de données (DEC-PARAM-10). Les pages légales sont hébergées
/// (Firebase Hosting) et ouvertes dans le navigateur via url_launcher.
class SectionConfidentialite extends StatelessWidget {
  /// Crée la section confidentialité.
  const SectionConfidentialite({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.parametresSectionConfidentialite,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.cardRadius,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.parametresConfidentialiteCorps,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Liens vers les pages légales hébergées (ouverture navigateur).
        _LienLegal(
          titre: l10n.parametresPolitiqueConfidentialite,
          onTap: () =>
              unawaited(_ouvrirUrl(context, LegalUrls.privacyPolicy)),
        ),
        const SizedBox(height: AppSpacing.xs),
        _LienLegal(
          titre: l10n.parametresConditionsUtilisation,
          onTap: () =>
              unawaited(_ouvrirUrl(context, LegalUrls.termsOfService)),
        ),
        const SizedBox(height: AppSpacing.xs),
        _LienLegal(
          titre: l10n.parametresMentionsLegales,
          onTap: () => unawaited(_ouvrirUrl(context, LegalUrls.legalNotice)),
        ),
      ],
    );
  }

  Future<void> _ouvrirUrl(BuildContext context, String url) async {
    unawaited(HapticFeedback.selectionClick());
    final uri = Uri.parse(url);
    // On NE gate PAS sur canLaunchUrl : sur Android 11+ il renvoie false
    // (« component name is null ») même quand launchUrl réussit (DEC-PARAM-05).
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

/// Ligne tappable vers une page légale (lien externe, navigateur).
class _LienLegal extends StatelessWidget {
  const _LienLegal({required this.titre, required this.onTap});

  final String titre;
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  titre,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.open_in_new,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
