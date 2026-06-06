import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/parametres/widgets/section_confidentialite.dart';
import 'package:digiharmony_app/pages/parametres/widgets/section_langue.dart';
import 'package:digiharmony_app/pages/parametres/widgets/section_projet.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Vue de l'écran Paramètres.
///
/// Toolbar : chevron retour · titre · espaceur (pas de burger, maquette).
/// Sections : Langue (cœur) · Confidentialité · Projet · Version.
/// LocaleBloc consommé directement (DEC-PARAM-02,
/// déjà au-dessus de MaterialApp).
class ParametresView extends StatelessWidget {
  /// Crée la vue Paramètres.
  const ParametresView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animer = !MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.text),
          iconSize: 32,
          padding: const EdgeInsets.all(AppSpacing.sm),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.parametresTitre,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        // Espaceur symétrique pour centrer le titre
        // (pas de burger — DEC-PARAM-11).
        actions: const [SizedBox(width: 48)],
      ),
      body: Stack(
        children: [
          // Halo en arrière-plan (a11y: statique si reduced motion).
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: HaloRespirant(
                key: ValueKey(animer),
                taille: 300,
                animer: animer,
              ),
            ),
          ),
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionLangue(),
                  SizedBox(height: AppSpacing.xl),
                  SectionConfidentialite(),
                  SizedBox(height: AppSpacing.xl),
                  SectionProjet(),
                  SizedBox(height: AppSpacing.xl),
                  _LigneVersion(),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne de version de l'app en bas de page.
///
/// Lit la version dynamiquement via PackageInfo (dérogation assumée
/// par l'utilisateur pour une version juste).
class _LigneVersion extends StatelessWidget {
  const _LigneVersion();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '—';
        return Text(
          l10n.parametresVersion(version),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        );
      },
    );
  }
}
