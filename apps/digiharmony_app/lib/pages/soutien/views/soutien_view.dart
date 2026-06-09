import 'dart:async';

import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/soutien/confiance/confiance_page.dart';
import 'package:digiharmony_app/pages/soutien/widgets/bloc_ligne_ecoute.dart';
import 'package:digiharmony_app/pages/soutien/widgets/bouton_action_soutien.dart';
import 'package:digiharmony_app/pages/soutien/widgets/halo_soutien.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Vue principale de l'ecran de soutien.
///
/// Halo doux + header (icone, titre, accroche, paragraphe) + 2 CTA
/// (Confiance primaire, Respiration secondaire STUB) +
/// bloc ligne d'ecoute conditionnel + "Plus tard" + "Aucune relance".
/// Tons bienveillants, jamais alarmants. (DEC-SO-003/009/010/012)
class SoutienView extends StatelessWidget {
  /// Cree la vue de soutien.
  const SoutienView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animer = !MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDeep,
        elevation: 0,
        leading: Semantics(
          label: l10n.soutienPlusTard,
          button: true,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.chevron_left, color: AppColors.text),
            iconSize: 32,
            padding: const EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/logo_digiharmony_square.png',
          height: 36,
          errorBuilder: (ctx, e, st) => const SizedBox(height: 36, width: 36),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: Stack(
        children: [
          // Halo en arriere-plan, derriere le contenu.
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: HaloSoutien(key: ValueKey(animer)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icone ronde douce
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.soutienTitre,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.soutienAccroche,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.soutienParagraphe,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // CTA primaire -> ConfiancePage
                  BoutonActionSoutien(
                    icone: Icons.volunteer_activism,
                    label: l10n.soutienCtaConfiance,
                    style: StyleBoutonSoutien.primaire,
                    onTap: () => _versConfiance(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // CTA secondaire — Respiration → exercice Respiration.
                  BoutonActionSoutien(
                    icone: Icons.air,
                    label: l10n.soutienCtaRespiration,
                    style: StyleBoutonSoutien.secondaire,
                    onTap: () => AppRouter.versRespiration(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Bloc ligne d'ecoute conditionnel
                  const BlocLigneEcoute(),
                  const SizedBox(height: AppSpacing.xl),
                  // Plus tard
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(
                      l10n.soutienPlusTard,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Aucune relance
                  Text(
                    l10n.soutienAucuneRelance,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _versConfiance(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ConfiancePage(),
        ),
      ),
    );
  }

}
