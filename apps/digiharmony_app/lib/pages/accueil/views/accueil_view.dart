import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/common/placeholder_screen.dart';
import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/pages/accueil/widgets/carte_humeur.dart';
import 'package:digiharmony_app/pages/accueil/widgets/particules_flottantes.dart';
import 'package:digiharmony_app/pages/accueil/widgets/pilule_action.dart';
import 'package:digiharmony_app/pages/accueil/widgets/tuile_outil.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Corps de l'écran Accueil — consomme [AccueilBloc].
class AccueilView extends StatelessWidget {
  /// Crée la vue Accueil.
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      // DEV-only — retiré du build release par tree-shaking (kDebugMode).
      // Permet de visualiser SoutienPage sans saisir 7 jours negatifs.
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              heroTag: 'debug_soutien',
              backgroundColor: AppColors.surface,
              tooltip: '[DEV] Voir SoutienPage',
              onPressed: () => AppRouter.versSoutien(context),
              child: const Icon(Icons.support, color: AppColors.primary),
            )
          : null,
      body: Stack(
        children: [
          // Décor animé en fond.
          const Positioned(
            top: -40,
            left: -60,
            child: HaloRespirant(),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ParticulesFlottantes(),
          ),
          // Contenu scrollable au-dessus du décor.
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header : logo + wordmark + bouton réglages.
                  _Header(l10n: l10n),
                  const SizedBox(height: AppSpacing.lg),
                  // Greeting fixe (DEC-HOME-04).
                  _Greeting(l10n: l10n),
                  const SizedBox(height: AppSpacing.lg),
                  // HeroCard états A/B pilotés par le Bloc.
                  BlocBuilder<AccueilBloc, AccueilState>(
                    builder: (context, state) {
                      if (state is AccueilChargement) {
                        return const _SkeletonHeroCard();
                      }
                      if (state is AccueilPret) {
                        return CarteHumeur(
                          humeur: state.humeurDuJour,
                          conseil: state.conseil,
                        );
                      }
                      // AccueilErreur → fallback État A (AC7).
                      return const CarteHumeur(
                        conseil: ConseilDuJourVue(cle: 'tipDay01'),
                        erreur: true,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Grille 2 tuiles.
                  BlocBuilder<AccueilBloc, AccueilState>(
                    builder: (context, state) {
                      final tipKey = state is AccueilPret
                          ? state.conseil.cle
                          : 'tipDay01';
                      final tipTexte = _resoudreConseil(context, tipKey);
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TuileOutil(
                              label: l10n.homeToolBubble,
                              icone: Icons.auto_awesome,
                              onTap: () => ouvrirPlaceholder(
                                context,
                                l10n.placeholderBulle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            TuileOutil(
                              label: l10n.homeToolDailyTip,
                              icone: Icons.lightbulb_outline,
                              description: tipTexte,
                              onTap: () => ouvrirPlaceholder(
                                context,
                                l10n.placeholderConseil,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Pilule « Faire une pause ».
                  Center(
                    child: PiluleAction(
                      label: l10n.homePauseCta,
                      icone: Icons.eco,
                      onTap: () =>
                          ouvrirPlaceholder(context, l10n.placeholderPause),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Lien tertiaire « Mon temps d'écran ».
                  Center(
                    child: TextButton.icon(
                      onPressed: () => ouvrirPlaceholder(
                        context,
                        l10n.placeholderTempsEcran,
                      ),
                      icon: const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      label: Text(
                        l10n.homeScreenTime,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
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

  /// Résout le texte du conseil depuis la clé i18n.
  String _resoudreConseil(BuildContext context, String cle) {
    final l10n = context.l10n;
    switch (cle) {
      case 'tipDay01':
        return l10n.tipDay01;
      case 'tipDay02':
        return l10n.tipDay02;
      case 'tipDay03':
        return l10n.tipDay03;
      case 'tipDay04':
        return l10n.tipDay04;
      case 'tipDay05':
        return l10n.tipDay05;
      case 'tipDay06':
        return l10n.tipDay06;
      case 'tipDay07':
        return l10n.tipDay07;
      default:
        return l10n.tipDay01;
    }
  }
}

/// Header : logo + wordmark + bouton réglages (DEC-003 : pas de toolbar haute).
class _Header extends StatelessWidget {
  const _Header({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo carré 40×40 avec coins arrondis (~10).
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/images/logo_digiharmony_square.png',
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Icon(
                Icons.favorite,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Wordmark — non traduit (AC8 / DEC-HOME-01).
        Text(
          l10n.homeBrandName.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        // Bouton réglages → PlaceholderScreen.
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.textMuted),
          tooltip: l10n.reglagesTooltip,
          onPressed: () => ouvrirPlaceholder(context, l10n.placeholderReglages),
        ),
      ],
    );
  }
}

/// Bloc greeting : titre fixe + sous-titre (DEC-HOME-04).
class _Greeting extends StatelessWidget {
  const _Greeting({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeGreeting,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.homeGreetingSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// Skeleton neutre pendant le chargement initial (HV-1, public mineur).
class _SkeletonHeroCard extends StatelessWidget {
  const _SkeletonHeroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 200,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.buttonRadius,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 14,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.buttonRadius,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 14,
              width: 160,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.buttonRadius,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
