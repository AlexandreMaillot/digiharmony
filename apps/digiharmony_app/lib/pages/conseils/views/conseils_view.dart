import 'dart:async';

import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/widgets/particules_flottantes.dart';
import 'package:digiharmony_app/pages/conseils/bloc/conseils_bloc.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:digiharmony_app/pages/conseils/widgets/_carte_shell.dart'
    show hauteurMinCarte;
import 'package:digiharmony_app/pages/conseils/widgets/carte_conseil_pratique.dart';
import 'package:digiharmony_app/pages/conseils/widgets/carte_emotion.dart';
import 'package:digiharmony_app/pages/conseils/widgets/carte_rappel.dart';
import 'package:digiharmony_app/pages/conseils/widgets/compteur_dots.dart';
import 'package:digiharmony_app/pages/conseils/widgets/hint_swipe.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Corps de l'écran Conseils — consomme [ConseilsBloc].
class ConseilsView extends StatefulWidget {
  /// Crée la vue Conseils.
  const ConseilsView({super.key});

  @override
  State<ConseilsView> createState() => _ConseilsViewState();
}

class _ConseilsViewState extends State<ConseilsView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.88, // peek de la carte suivante
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _allerA(int index) {
    if (_pageController.hasClients) {
      unawaited(
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return BlocListener<ConseilsBloc, ConseilsState>(
      listenWhen: (prev, curr) => prev.indexCourant != curr.indexCourant,
      listener: (context, state) {
        // Synchronise le PageView quand l'index change via les événements
        // (flèches, tap zones) — pas de boucle car onPageChanged est la
        // source de vérité pour les swipes directs.
        if (_pageController.hasClients) {
          final page = _pageController.page?.round();
          if (page != state.indexCourant) {
            _allerA(state.indexCourant);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: BlocBuilder<ConseilsBloc, ConseilsState>(
          builder: (context, state) {
            final carte = state.carteCourante;
            final accent =
                carte != null ? accentDeCarte(carte) : AppColors.primary;

            return Stack(
              children: [
                // Halo teinté accent courant (DEC-CO-11 / Q-CO-11).
                Positioned(
                  top: -60,
                  left: -80,
                  child: HaloRespirant(
                    taille: 360,
                    couleurs: [
                      accent.withValues(alpha: 0.16),
                      accent.withValues(alpha: 0.06),
                      AppColors.backgroundDeep.withValues(alpha: 0),
                    ],
                    animer: disableAnimations ? false : null,
                  ),
                ),
                // Particules (OFF si reduced-motion).
                if (!disableAnimations)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ParticulesFlottantes(),
                  ),
                // Contenu principal
                SafeArea(
                  child: Column(
                    children: [
                      _Toolbar(accent: accent),
                      const SizedBox(height: AppSpacing.sm),
                      // Compteur dots
                      if (state.status == ConseilsStatus.pret &&
                          state.deck.isNotEmpty)
                        _CompteurDotsRow(
                          state: state,
                          accent: accent,
                        ),
                      const SizedBox(height: AppSpacing.md),
                      // Deck de cartes
                      Expanded(child: _CorpsDeck(
                        state: state,
                        pageController: _pageController,
                        disableAnimations: disableAnimations,
                      )),
                      // Barre de navigation : flèches tap + hint
                      // (a11y DEC-CO-08)
                      HintSwipe(
                        visible: state.deck.length > 1 &&
                            state.status == ConseilsStatus.pret,
                        disableAnimations: disableAnimations,
                        aPrecedent: state.aPrecedent,
                        aSuivant: state.aSuivant,
                        onPrecedent: () => context
                            .read<ConseilsBloc>()
                            .add(const ConseilsCartePrecedente()),
                        onSuivant: () => context
                            .read<ConseilsBloc>()
                            .add(const ConseilsCarteSuivante()),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Toolbar ────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Chevron retour (48×48 tap — a11y)
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              color: AppColors.text,
              tooltip: l10n.conseilsRetourTooltip,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Titre centré
          Expanded(
            child: Text(
              l10n.conseilsTitre,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          // Espaceur 48 (symétrie — pas de burger, DEC-CO-12)
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

// ─── Compteur dots ────────────────────────────────────────────────────────

class _CompteurDotsRow extends StatelessWidget {
  const _CompteurDotsRow({
    required this.state,
    required this.accent,
  });

  final ConseilsState state;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: CompteurDots(
        total: state.deck.length,
        indexCourant: state.indexCourant,
        accentCourant: accent,
        label: l10n.conseilsCompteurSemantique(
          state.indexCourant + 1,
          state.deck.length,
        ),
      ),
    );
  }
}

// ─── Deck de cartes ────────────────────────────────────────────────────────

class _CorpsDeck extends StatelessWidget {
  const _CorpsDeck({
    required this.state,
    required this.pageController,
    required this.disableAnimations,
  });

  final ConseilsState state;
  final PageController pageController;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    if (state.status == ConseilsStatus.initial ||
        state.status == ConseilsStatus.chargement) {
      return const _SkeletonDeck();
    }

    if (state.deck.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: context.l10n.conseilsCarteSemantique(
        state.indexCourant + 1,
        state.deck.length,
      ),
      customSemanticsActions: {
        CustomSemanticsAction(label: context.l10n.conseilsHintSuivant): () {
          context.read<ConseilsBloc>().add(const ConseilsCarteSuivante());
        },
        CustomSemanticsAction(
          label: context.l10n.conseilsHintPrecedent,
        ): () {
          context.read<ConseilsBloc>().add(const ConseilsCartePrecedente());
        },
      },
      child: PageView.builder(
        controller: pageController,
        itemCount: state.deck.length,
        onPageChanged: (i) {
          context.read<ConseilsBloc>().add(ConseilsCarteAtteinte(i));
        },
        itemBuilder: (context, index) {
          final carte = state.deck[index];
          final accent = accentDeCarte(carte);
          return _CarteItem(
            carte: carte,
            accent: accent,
            index: index,
            total: state.deck.length,
            actif: index == state.indexCourant,
            disableAnimations: disableAnimations,
          );
        },
      ),
    );
  }
}

// ─── Item de carte ────────────────────────────────────────────────────────

class _CarteItem extends StatefulWidget {
  const _CarteItem({
    required this.carte,
    required this.accent,
    required this.index,
    required this.total,
    required this.actif,
    required this.disableAnimations,
  });

  final CarteConseil carte;
  final Color accent;
  final int index;
  final int total;

  /// Vrai si cette carte est la carte active (anime le swipe-hint).
  final bool actif;

  /// Si vrai (reduced-motion), le swipe-hint est désactivé (carte statique).
  final bool disableAnimations;

  @override
  State<_CarteItem> createState() => _CarteItemState();
}

class _CarteItemState extends State<_CarteItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Swipe-hint : oscillation douce (~3.5 s, infinie) de la carte active.
    // rotate -2° → +1.5° + légère translation X (maquette new_screen13).
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _majAnimation();
  }

  @override
  void didUpdateWidget(_CarteItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actif != widget.actif ||
        oldWidget.disableAnimations != widget.disableAnimations) {
      _majAnimation();
    }
  }

  void _majAnimation() {
    if (widget.actif && !widget.disableAnimations) {
      if (!_controller.isAnimating) {
        unawaited(_controller.repeat(reverse: true));
      }
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // La carte remplit la hauteur du viewport du PageView (hauteur cohérente
    // quelle que soit la quantité de contenu), avec un plancher à
    // [hauteurMinCarte]. Scroll interne UNIQUEMENT en cas de débordement
    // (gros textes / a11y) — sinon la carte est centrée et ne se tasse pas.
    final carte = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 335),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hauteurDispo = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : hauteurMinCarte;
              final hauteurCarte = hauteurDispo > hauteurMinCarte
                  ? hauteurDispo
                  : hauteurMinCarte;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: hauteurCarte),
                  child: IntrinsicHeight(child: _buildCarte(context)),
                ),
              );
            },
          ),
        ),
      ),
    );

    if (!widget.actif || widget.disableAnimations) {
      return carte;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // t ∈ [0,1] → rotation -2° (= -0.0349 rad) à +1.5° (= 0.0262 rad).
        final t = _controller.value;
        final angle = (-2 + t * 3.5) * 3.1415926535 / 180;
        final dx = (t - 0.5) * 8; // translation X douce ± 4 px
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.rotate(
            angle: angle,
            child: child,
          ),
        );
      },
      child: carte,
    );
  }

  Widget _buildCarte(BuildContext context) {
    return switch (widget.carte) {
      CarteRappel() => CarteRappelWidget(
          carte: widget.carte as CarteRappel,
          accent: widget.accent,
        ),
      CarteEmotion() => CarteEmotionWidget(
          carte: widget.carte as CarteEmotion,
          accent: widget.accent,
        ),
      CarteConseilPratique() => CarteConseilPratiqueWidget(
          carte: widget.carte as CarteConseilPratique,
          accent: widget.accent,
        ),
    };
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────

class _SkeletonDeck extends StatelessWidget {
  const _SkeletonDeck();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: AppRadii.cardRadius,
        ),
      ),
    );
  }
}
