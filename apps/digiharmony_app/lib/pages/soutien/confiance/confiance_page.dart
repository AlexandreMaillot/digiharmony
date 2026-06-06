import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Ecran de confiance — pistes bienveillantes locales.
///
/// Accessible uniquement via le CTA primaire de SoutienView.
/// Aucun formulaire, aucun reseau, aucune collecte, aucun numero.
/// Textes placeholders a valider par les partenaires (public mineur, Erasmus+).
/// Retour = pop. (DEC-SO-006)
class ConfiancePage extends StatelessWidget {
  /// Cree la page de confiance.
  const ConfiancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final pistes = [
      l10n.soutienConfiancePiste01,
      l10n.soutienConfiancePiste02,
      l10n.soutienConfiancePiste03,
      l10n.soutienConfiancePiste04,
      l10n.soutienConfiancePiste05,
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDeep,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: AppColors.text),
          iconSize: 32,
          padding: const EdgeInsets.all(AppSpacing.sm),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        title: Image.asset(
          'assets/images/logo_digiharmony_square.png',
          height: 36,
          errorBuilder: (ctx, e, st) => const SizedBox(height: 36, width: 36),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.soutienConfianceTitre,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.soutienConfianceParagraphe,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                color: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.cardRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pistes
                        .map(
                          (piste) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    top: 4,
                                    right: AppSpacing.sm,
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    piste,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.text,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
