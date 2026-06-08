import 'dart:async';
import 'dart:math' as math;
import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/bulles/routes_bulles.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/widgets/barre_outils.dart';
import 'package:digiharmony_app/widgets/fond_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Hub « Choisis ta bulle » — selection d'une categorie d'exercice.
///
/// Grille 2x2 organique de 4 bulles animees (glow + anneau shimmer rotatif +
/// flottement vertical dephase). Les boucles decoratives respectent
/// `reduceMotion` (`MediaQuery.disableAnimations`).
class BullesPage extends StatelessWidget {
  /// {@macro bulles_page}
  const BullesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BullesView();
  }
}

/// Texte (label, duree, hint) d'une bulle, resolu depuis l'ARB par categorie.
class _TextesBulle {
  const _TextesBulle({
    required this.label,
    required this.duree,
    required this.hint,
  });

  /// Resout les 3 cles i18n correspondant a [id].
  factory _TextesBulle.pour(IdCategorieBulle id, AppLocalizations l10n) {
    return switch (id) {
      IdCategorieBulle.respiration => _TextesBulle(
        label: l10n.bubblesRespirationLabel,
        duree: l10n.bubblesRespirationDuration,
        hint: l10n.bubblesRespirationHint,
      ),
      IdCategorieBulle.senses => _TextesBulle(
        label: l10n.bubblesSensesLabel,
        duree: l10n.bubblesSensesDuration,
        hint: l10n.bubblesSensesHint,
      ),
      IdCategorieBulle.stretch => _TextesBulle(
        label: l10n.bubblesStretchLabel,
        duree: l10n.bubblesStretchDuration,
        hint: l10n.bubblesStretchHint,
      ),
      IdCategorieBulle.detox => _TextesBulle(
        label: l10n.bubblesDetoxLabel,
        duree: l10n.bubblesDetoxDuration,
        hint: l10n.bubblesDetoxHint,
      ),
    };
  }

  final String label;
  final String duree;
  final String hint;
}

/// UI du hub.
class BullesView extends StatelessWidget {
  /// {@macro bulles_view}
  const BullesView({super.key});

  Future<void> _onBulleTap(BuildContext context, IdCategorieBulle id) async {
    await HapticFeedback.selectionClick();
    if (!context.mounted) return;
    final database = context.read<AppDatabase>();
    if (!context.mounted) return;
    await Navigator.of(context).push(RoutesBulles.pourCategorie(id, database));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    const categories = CategorieBulle.all;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: BarreOutils(
        title: l10n.notifGuideBrand,
        backLabel: l10n.bubblesToolbarBack,
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: FondApplication(
        background: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Column(
                  children: [
                    Text(
                      l10n.bubblesTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.bubblesSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Colonne gauche : bulles 0 et 2.
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CarteBulle(
                              categorie: categories[0],
                              textes: _TextesBulle.pour(categories[0].id, l10n),
                              index: 0,
                              reduceMotion: reduceMotion,
                              onTap: () =>
                                  _onBulleTap(context, categories[0].id),
                            ),
                            _CarteBulle(
                              categorie: categories[2],
                              textes: _TextesBulle.pour(categories[2].id, l10n),
                              index: 2,
                              reduceMotion: reduceMotion,
                              onTap: () =>
                                  _onBulleTap(context, categories[2].id),
                            ),
                          ],
                        ),
                      ),
                      // Colonne droite : decalee plus bas (rythme organique).
                      // Decalage via Transform pour ne pas ajouter de
                      // contrainte verticale (evite tout debordement).
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(0, 26),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _CarteBulle(
                                categorie: categories[1],
                                textes:
                                    _TextesBulle.pour(categories[1].id, l10n),
                                index: 1,
                                reduceMotion: reduceMotion,
                                onTap: () =>
                                    _onBulleTap(context, categories[1].id),
                              ),
                              _CarteBulle(
                                categorie: categories[3],
                                textes:
                                    _TextesBulle.pour(categories[3].id, l10n),
                                index: 3,
                                reduceMotion: reduceMotion,
                                onTap: () =>
                                    _onBulleTap(context, categories[3].id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Text(
                  l10n.bubblesOfflineHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bulle organique d'une categorie : cercle translucide + glow + anneau
/// shimmer rotatif, contenu centre (icone, label, badge duree) et hint dessous.
class _CarteBulle extends StatelessWidget {
  const _CarteBulle({
    required this.categorie,
    required this.textes,
    required this.index,
    required this.reduceMotion,
    required this.onTap,
  });

  /// Diametre du cercle de la bulle.
  static const double _diametre = 156;

  final CategorieBulle categorie;
  final _TextesBulle textes;
  final int index;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = categorie.color;

    final cercle = SizedBox(
      width: _diametre,
      height: _diametre,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fond translucide + glow doux couleur categorie.
          Container(
            width: _diametre,
            height: _diametre,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: couleur.withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: couleur.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: -4,
                ),
              ],
            ),
          ),
          // Anneau shimmer rotatif (arc en degrade conique).
          _AnneauShimmer(couleur: couleur, reduceMotion: reduceMotion),
          // Contenu centre.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: couleur.withValues(alpha: 0.22),
                ),
                child: Icon(categorie.icon, color: couleur, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                textes.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  textes.duree,
                  style: TextStyle(
                    color: couleur,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final colonne = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: '${textes.label}, ${textes.duree}',
          child: InkResponse(
            onTap: onTap,
            radius: _diametre / 2,
            customBorder: const CircleBorder(),
            child: cercle,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: _diametre,
          child: Text(
            textes.hint,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ),
      ],
    );

    if (reduceMotion) return colonne;

    // Apparition douce puis flottement vertical en boucle, dephase par index.
    return colonne
        .animate()
        .fadeIn(duration: 450.ms, delay: (index * 90).ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 450.ms,
          curve: Curves.easeOut,
        )
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -10,
          duration: (2600 + index * 350).ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Anneau decoratif : arc lumineux (degrade conique) qui tourne lentement
/// autour de la bulle. Coupe la rotation si `reduceMotion`.
class _AnneauShimmer extends StatefulWidget {
  const _AnneauShimmer({required this.couleur, required this.reduceMotion});

  final Color couleur;
  final bool reduceMotion;

  @override
  State<_AnneauShimmer> createState() => _AnneauShimmerState();
}

class _AnneauShimmerState extends State<_AnneauShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (!widget.reduceMotion) unawaited(_controller.repeat());
  }

  @override
  void didUpdateWidget(_AnneauShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion && _controller.isAnimating) {
      _controller.stop();
    } else if (!widget.reduceMotion && !_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peintre = _PeintreAnneauShimmer(couleur: widget.couleur);
    final anneau = SizedBox(
      width: _CarteBulle._diametre,
      height: _CarteBulle._diametre,
      child: CustomPaint(painter: peintre),
    );

    if (widget.reduceMotion) {
      // Anneau statique, lisible, sans rotation.
      return IgnorePointer(child: anneau);
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            );
          },
          child: anneau,
        ),
      ),
    );
  }
}

/// Peint un anneau fin avec un degrade conique (arc lumineux -> transparent).
class _PeintreAnneauShimmer extends CustomPainter {
  const _PeintreAnneauShimmer({required this.couleur});

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final rayon = size.width / 2 - 2;
    final rect = Rect.fromCircle(center: centre, radius: rayon);

    final degrade = SweepGradient(
      colors: [
        couleur.withValues(alpha: 0),
        couleur.withValues(alpha: 0.55),
        couleur.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.18, 0.42],
    );

    final pinceau = Paint()
      ..shader = degrade.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(centre, rayon, pinceau);
  }

  @override
  bool shouldRepaint(_PeintreAnneauShimmer oldDelegate) =>
      oldDelegate.couleur != couleur;
}
