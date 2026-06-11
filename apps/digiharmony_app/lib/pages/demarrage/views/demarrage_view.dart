import 'dart:async';

import 'package:digiharmony_app/app/shell/main_shell.dart';
import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/widgets/anneaux_ondes.dart';
import 'package:digiharmony_app/pages/demarrage/widgets/barre_signature.dart';
import 'package:digiharmony_app/pages/demarrage/widgets/points_chargement.dart';
import 'package:digiharmony_app/pages/soutien/bloc/soutien_bloc.dart';
import 'package:digiharmony_app/pages/soutien/declenchement/evaluateur_soutien.dart';
import 'package:digiharmony_app/pages/soutien/views/soutien_page.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Durée minimale perçue du splash en mode normal.
const dureeMinimaleNormale = Duration(milliseconds: 2500);

/// Durée minimale perçue du splash en reduced motion (DEC-S-005).
const dureeMinimaleReduite = Duration(milliseconds: 800);

/// Vue du démarrage (splash) : marque animée + routage automatique.
///
/// Lit `MediaQuery.disableAnimations` pour (a) désactiver les boucles et
/// (b) réduire la durée minimale (DEC-S-005), puis envoie `DemarrageDemarre`.
class DemarrageView extends StatefulWidget {
  /// Crée la vue du démarrage.
  const DemarrageView({super.key});

  @override
  State<DemarrageView> createState() => _DemarrageViewState();
}

class _DemarrageViewState extends State<DemarrageView> {
  var _demarre = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_demarre) return;
    _demarre = true;
    final reduit = MediaQuery.of(context).disableAnimations;
    context.read<DemarrageBloc>().add(
      DemarrageDemarre(
        dureeMinimale: reduit ? dureeMinimaleReduite : dureeMinimaleNormale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animer = !MediaQuery.of(context).disableAnimations;
    final l10n = context.l10n;

    return BlocListener<DemarrageBloc, DemarrageState>(
      listener: _onEtat,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BlocMarque(animer: animer, l10n: l10n),
                      const SizedBox(height: AppSpacing.xl),
                      PointsChargement(animer: animer),
                    ],
                  ),
                ),
              ),
              const _FooterFinancement(),
            ],
          ),
        ),
      ),
    );
  }

  void _onEtat(BuildContext context, DemarrageState state) {
    switch (state) {
      case DemarrageInitial():
      case DemarrageEnCours():
        break;
      case DemarragePret():
      case DemarrageErreur():
        // L'onboarding est abandonné : on route toujours vers l'Accueil
        // (DEC-PROD-2026). BienvenueBloc reste dormant.
        unawaited(_versAccueilPuisEvaluerSoutien(context));
    }
  }

  /// Route vers l'Accueil puis évalue le déclenchement du soutien.
  ///
  /// Append-only : ne modifie pas le comportement existant (Accueil toujours
  /// affiché).
  ///
  /// Correctif séquence (DEC-SO-003/004) :
  /// `pushReplacement(Accueil)` démonte `DemarrageView`, ce qui invalide le
  /// `BuildContext`. Pour éviter que le guard `context.mounted` court-circuite
  /// la branche soutien avant l'évaluation, on :
  ///   1. capture `navigator`, `db`, `soutienBloc` et `dejaMontre` TANT QUE
  ///      le widget est encore monté (avant tout `await`) ;
  ///   2. appelle `compterSaisiesNegativesConsecutives()` (seul await avant
  ///      toute navigation) ;
  ///   3. effectue toutes les navigations sur le `NavigatorState` capturé,
  ///      sans dépendre du contexte démonté.
  Future<void> _versAccueilPuisEvaluerSoutien(BuildContext context) async {
    // ── Capture avant tout await ──────────────────────────────────────────
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    final db = context.read<AppDatabase>();
    final soutienBloc = context.read<SoutienBloc>();
    final dejaMontre = soutienBloc.state.dejaMontrePourEpisodeEnCours;

    // ── Lecture du compteur (seul await avant navigation) ─────────────────
    final compteur = await db.compterSaisiesNegativesConsecutives();

    // ── Décision avant de démonter le contexte ────────────────────────────
    // Réarmement : compteur redescendu < seuil alors que le flag est posé.
    if (compteur < EvaluateurSoutien.seuil && dejaMontre) {
      soutienBloc.add(const SoutienReinitialise());
    }

    final doitDeclencher = EvaluateurSoutien.doitDeclencher(
      compteurNegativesConsecutives: compteur,
      dejaMontrePourEpisodeEnCours:
          soutienBloc.state.dejaMontrePourEpisodeEnCours,
    );

    // ── Navigation via NavigatorState capturé (contexte déjà potentiellement
    //    démonté à ce stade — on n'en dépend plus) ─────────────────────────
    //
    // `pushReplacement` retourne une Future qui ne se résout que quand la
    // route poussée est elle-même poppée (ce qui n'arrive jamais pour
    // MainShell). On ne l'attend PAS : on lance et on continue.
    unawaited(navigator.pushReplacement(MainShell.route()));

    if (doitDeclencher) {
      // Marquage à l'affichage (DEC-SO-004).
      soutienBloc.add(const SoutienMontre());
      // `push` sur la même SoutienPage : même logique — ne pas awaiter.
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(builder: (_) => const SoutienPage()),
        ),
      );
    }
  }
}

/// Bloc marque : logo animé + anneaux + titre + tagline.
class _BlocMarque extends StatelessWidget {
  const _BlocMarque({required this.animer, required this.l10n});

  final bool animer;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final titre = Text(
      l10n.homeBrandName.toUpperCase(),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              HaloRespirant(
                taille: 240,
                couleurs: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0),
                ],
                opaciteStatique: 0.5,
                animer: animer,
              ),
              AnneauxOndes(animer: animer),
              _LogoAnime(animer: animer),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (animer)
          titre.animate().fadeIn(delay: 400.ms, duration: 600.ms)
        else
          titre,
        const SizedBox(height: AppSpacing.md),
        const BarreSignature(),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.splashTagline,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Logo carré animé (pulsation douce en boucle).
class _LogoAnime extends StatelessWidget {
  const _LogoAnime({required this.animer});

  final bool animer;

  @override
  Widget build(BuildContext context) {
    final logo = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      child: Image.asset(
        'assets/images/logo_digiharmony_square.png',
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
      ),
    );

    if (!animer) return logo;

    return logo
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 0.97,
          end: 1.03,
          duration: 2400.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Footer avec logo de financement européen.
class _FooterFinancement extends StatelessWidget {
  const _FooterFinancement();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Image.asset(
            'assets/images/logo_eu_funding.png',
            width: 120,
            errorBuilder: (context, error, stack) =>
                const SizedBox(height: 32, width: 120),
          ),
        ),
      ],
    );
  }
}
