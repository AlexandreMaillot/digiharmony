import 'dart:async';

import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/app/shell/main_shell.dart';
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
import 'package:flutter_animate/flutter_animate.dart';
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
                              onTap: () => _ouvrirSection(
                                context,
                                OngletPrincipal.bulles,
                                AppRouter.versBulles,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            TuileOutil(
                              label: l10n.homeToolDailyTip,
                              icone: Icons.lightbulb_outline,
                              description: tipTexte,
                              accent: AppColors.accentGold,
                              onTap: () => _ouvrirSection(
                                context,
                                OngletPrincipal.conseils,
                                AppRouter.versConseils,
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
                      accent: AppColors.successVert,
                      onTap: () => AppRouter.versDetox(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Lien tertiaire « Mon temps d'écran ».
                  Center(
                    child: TextButton.icon(
                      onPressed: () => AppRouter.versTempsEcran(context),
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
  ///
  /// Couvre toutes les clés que `conseilDuJour` peut désormais renvoyer :
  /// tipDay01..07 (rappels historiques) + conseilRappelPresent/Likes
  /// + cartes conseil pratique. Les cartes émotion ne peuvent jamais
  /// arriver ici (conseilDuJour filtre type_carte != 'emotion', DEC-CO-11).
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
      // Nouveaux rappels/conseils génériques (corpus v4) — headline court.
      case 'conseilRappelPresent':
        return l10n.conseilRappelPresentCitation1;
      case 'conseilRappelLikes':
        return l10n.conseilRappelLikesCitation1;
      case 'conseilPratiqueInteractions':
        return l10n.conseilPratiqueInteractionsHeadline;
      case 'conseilPratiqueEspace':
        return l10n.conseilPratiqueEspaceHeadline;
      default:
        return l10n.tipDay01;
    }
  }
}

/// Ouvre une section qui est aussi un onglet de la bottom bar.
///
/// Sous [MainShell] : bascule l'onglet (pas d'empilement, pas de retour —
/// DEC-NAV-2026). Hors shell (prévisualisation `main_development`, tests) :
/// retombe sur l'ancienne navigation empilée via [repli].
void _ouvrirSection(
  BuildContext context,
  OngletPrincipal onglet,
  Future<void> Function(BuildContext) repli,
) {
  final shell = ShellScope.maybeOf(context);
  if (shell != null) {
    shell.allerVers(onglet);
  } else {
    unawaited(repli(context));
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
        // Logo avec anneau dégradé animé (tournant).
        const _LogoAnime(),
        const SizedBox(width: AppSpacing.md),
        // Wordmark — non traduit (AC8 / DEC-HOME-01).
        Text(
          l10n.homeBrandName.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

/// Logo dans un anneau dégradé « signature » qui tourne en continu.
///
/// a11y : si `MediaQuery.disableAnimations` est vrai, l'anneau est statique
/// (DEC-HOME-07 — reduced-motion).
class _LogoAnime extends StatelessWidget {
  const _LogoAnime();

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    const taille = 54.0;

    Widget anneau = Container(
      width: taille,
      height: taille,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            AppColors.primary,
            AppColors.successVert,
            AppColors.accentGold,
            AppColors.primary,
          ],
        ),
      ),
    );
    if (!reduce) {
      anneau = anneau
          .animate(onPlay: (c) => c.repeat())
          .rotate(duration: const Duration(seconds: 6));
    }

    return SizedBox(
      width: taille,
      height: taille,
      child: Stack(
        alignment: Alignment.center,
        children: [
          anneau,
          // Trou central : punch couleur de fond pour ne garder qu'un anneau.
          Container(
            width: taille - 7,
            height: taille - 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
          ),
          // Logo rond.
          ClipOval(
            child: Image.asset(
              'assets/images/logo_digiharmony_square.png',
              width: taille - 13,
              height: taille - 13,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: taille - 13,
                height: taille - 13,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloc greeting : titre fixe + sous-titre (DEC-HOME-04).
class _Greeting extends StatelessWidget {
  const _Greeting({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    // On isole l'emoji 👋 pour l'agrandir et l'animer séparément du texte.
    final salut = l10n.homeGreeting.replaceAll('👋', '').trim();

    Widget main = const Text('👋', style: TextStyle(fontSize: 34));
    if (!reduce) {
      main = main.animate(onPlay: (c) => c.repeat(reverse: true)).rotate(
            begin: -0.04,
            end: 0.06,
            duration: const Duration(milliseconds: 600),
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                salut,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            main,
          ],
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
