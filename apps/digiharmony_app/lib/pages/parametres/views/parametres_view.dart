import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/parametres/widgets/section_confidentialite.dart';
import 'package:digiharmony_app/pages/parametres/widgets/section_langue.dart';
import 'package:digiharmony_app/pages/parametres/widgets/section_projet.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  _BoutonContact(),
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

/// Bouton « Contacter DigiHarmony » en bas des Paramètres.
///
/// Ouvre l'app mail par défaut vers [_email] (url_launcher, scheme mailto).
/// En cas d'échec (pas de client mail), affiche un SnackBar discret.
class _BoutonContact extends StatelessWidget {
  const _BoutonContact();

  static const String _email = 'contact@digiharmonie.com';

  Future<void> _contacter(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(scheme: 'mailto', path: _email);
    var succes = false;
    try {
      succes = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      succes = false;
    }
    if (!succes) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.parametresLienIndisponible)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OutlinedButton.icon(
      onPressed: () => _contacter(context),
      icon: const Icon(Icons.mail_outline),
      label: Text(l10n.parametresContactBouton),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size.fromHeight(48),
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
