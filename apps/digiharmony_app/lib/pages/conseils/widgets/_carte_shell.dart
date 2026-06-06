import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

// Composants internes partagés par les 3 types de cartes Conseils.
// Préfixe underscore dans le nom de fichier = usage interne seulement.

/// Hauteur minimale d'une carte du deck (maquette new_screen13 : `minHeight
/// 440px`). La carte remplit la zone du deck quelle que soit la quantité de
/// contenu (pas de tassement / grand vide sous la carte).
const double hauteurMinCarte = 440;

/// Coquille de carte avec streak accent, clouds décoratifs et fond surface.
///
/// La carte adopte une **hauteur cohérente** : elle remplit la hauteur
/// disponible du deck (côté appelant) tout en garantissant un plancher de
/// [hauteurMinCarte]. Le [child] est un `Column` distribué (`spaceBetween`)
/// — voir les cartes rappel/emotion/conseil.
class ContenuCarte extends StatelessWidget {
  const ContenuCarte({required this.accent, required this.child, super.key});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: accent.withValues(alpha: 0.30),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      // Le contenu est l'enfant DIMENSIONNANT du Stack (non `Positioned`) afin
      // de contribuer à la hauteur intrinsèque (l'appelant l'entoure d'un
      // `IntrinsicHeight` + `minHeight` pour remplir le viewport). Les éléments
      // décoratifs (clouds, streak) sont `Positioned` (sans effet de taille).
      child: Stack(
        children: [
          // Cloud radial haut-gauche
          Positioned(
            top: -30,
            left: -30,
            child: _Cloud(couleur: accent.withValues(alpha: 0.15), taille: 120),
          ),
          // Cloud radial bas-droit
          Positioned(
            bottom: -30,
            right: -30,
            child: _Cloud(couleur: accent.withValues(alpha: 0.10), taille: 100),
          ),
          // Streak accent 4 px en haut — dégradé horizontal qui s'estompe
          // à gauche ET à droite (transparent → accent → transparent),
          // conforme maquette new_screen13.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0),
                    accent,
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Contenu principal (enfant dimensionnant) — Column `spaceBetween`
          // distribué sur la hauteur (maquette : padding px-7 py-8 = 28h/32v).
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 32,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.couleur, required this.taille});

  final Color couleur;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [couleur, Colors.transparent]),
      ),
    );
  }
}

/// Tag compact (icône + libellé) teinté par [accent].
class TagCarte extends StatelessWidget {
  const TagCarte({
    required this.label,
    required this.accent,
    required this.icone,
    super.key,
  });

  final String label;
  final Color accent;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: AppRadii.buttonRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: accent),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Puce Do (✓ rond accent) pour listes Do's.
class PuceDo extends StatelessWidget {
  const PuceDo({required this.texte, required this.accent, super.key});

  final String texte;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
            ),
            child: Icon(Icons.check, size: 12, color: accent),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              texte,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Puce Don't (✗ rond gris) pour listes Don'ts.
class PuceDont extends StatelessWidget {
  const PuceDont({required this.texte, super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textMuted.withValues(alpha: 0.18),
            ),
            child: const Icon(
              Icons.close,
              size: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              texte,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Résout une clé i18n du corpus Conseils (PLACEHOLDER à valider partenaires).
///
/// Centralise toutes les clés ARB du corpus en un seul endroit. Retourne la
/// clé brute si elle n'est pas encore mappée (graceful degradation).
String resoudreCleCorpus(AppLocalizations l10n, String cle) {
  return _clesCorp[cle]?.call(l10n) ?? '';
}

/// Résout une liste de lignes (Do's ou Don'ts) depuis les ARB.
///
/// [nb] = nombre de lignes attendues (3 Do's ou 2 Don'ts).
List<String> resoudreLignes(
  AppLocalizations l10n,
  String cleBase,
  String suffixe,
  int nb,
) {
  return List.generate(nb, (i) {
    final cle = '$cleBase$suffixe${i + 1}';
    return resoudreCleCorpus(l10n, cle);
  }).where((s) => s.isNotEmpty).toList();
}

// Tableau centralisé des clés ARB du corpus Conseils.
// Format : 'cleARB' → (l10n) => valeur.
// PLACEHOLDER — contenu à valider partenaires Erasmus+ (DEC-CO-10).
final Map<String, String Function(AppLocalizations)> _clesCorp = {
  // ── tipDay01..07 (rappels) ────────────────────────────────────────────
  'tipDay01Tag': (l) => l.conseilsTagRappel,
  'tipDay01Citation1': (l) => l.tipDay01,
  'tipDay01Citation2': (_) => '',
  'tipDay01SousTexte': (_) => '',
  'tipDay02Tag': (l) => l.conseilsTagRappel,
  'tipDay02Citation1': (l) => l.tipDay02,
  'tipDay02Citation2': (_) => '',
  'tipDay02SousTexte': (_) => '',
  'tipDay03Tag': (l) => l.conseilsTagRappel,
  'tipDay03Citation1': (l) => l.tipDay03,
  'tipDay03Citation2': (_) => '',
  'tipDay03SousTexte': (_) => '',
  'tipDay04Tag': (l) => l.conseilsTagRappel,
  'tipDay04Citation1': (l) => l.tipDay04,
  'tipDay04Citation2': (_) => '',
  'tipDay04SousTexte': (_) => '',
  'tipDay05Tag': (l) => l.conseilsTagRappel,
  'tipDay05Citation1': (l) => l.tipDay05,
  'tipDay05Citation2': (_) => '',
  'tipDay05SousTexte': (_) => '',
  'tipDay06Tag': (l) => l.conseilsTagRappel,
  'tipDay06Citation1': (l) => l.tipDay06,
  'tipDay06Citation2': (_) => '',
  'tipDay06SousTexte': (_) => '',
  'tipDay07Tag': (l) => l.conseilsTagRappel,
  'tipDay07Citation1': (l) => l.tipDay07,
  'tipDay07Citation2': (_) => '',
  'tipDay07SousTexte': (_) => '',
  // ── conseilRappelPresent ──────────────────────────────────────────────
  'conseilRappelPresentTag': (l) => l.conseilsTagEquilibre,
  'conseilRappelPresentCitation1': (l) => l.conseilRappelPresentCitation1,
  'conseilRappelPresentCitation2': (l) => l.conseilRappelPresentCitation2,
  'conseilRappelPresentSousTexte': (l) => l.conseilRappelPresentSousTexte,
  // ── conseilRappelLikes ────────────────────────────────────────────────
  'conseilRappelLikesTag': (l) => l.conseilsTagEquilibre,
  'conseilRappelLikesCitation1': (l) => l.conseilRappelLikesCitation1,
  'conseilRappelLikesCitation2': (l) => l.conseilRappelLikesCitation2,
  'conseilRappelLikesSousTexte': (l) => l.conseilRappelLikesSousTexte,
  // ── conseilPratiqueInteractions ───────────────────────────────────────
  'conseilPratiqueInteractionsTag': (l) => l.conseilsTagConseilPratique,
  'conseilPratiqueInteractionsHeadline': (l) =>
      l.conseilPratiqueInteractionsHeadline,
  'conseilPratiqueInteractionsDo1': (l) => l.conseilPratiqueInteractionsDo1,
  'conseilPratiqueInteractionsDo2': (l) => l.conseilPratiqueInteractionsDo2,
  'conseilPratiqueInteractionsDo3': (l) => l.conseilPratiqueInteractionsDo3,
  'conseilPratiqueInteractionsDont1': (l) =>
      l.conseilPratiqueInteractionsDont1,
  'conseilPratiqueInteractionsDont2': (l) =>
      l.conseilPratiqueInteractionsDont2,
  // ── conseilPratiqueEspace ─────────────────────────────────────────────
  'conseilPratiqueEspaceTag': (l) => l.conseilsTagConseilPratique,
  'conseilPratiqueEspaceHeadline': (l) => l.conseilPratiqueEspaceHeadline,
  'conseilPratiqueEspaceDo1': (l) => l.conseilPratiqueEspaceDo1,
  'conseilPratiqueEspaceDo2': (l) => l.conseilPratiqueEspaceDo2,
  'conseilPratiqueEspaceDo3': (l) => l.conseilPratiqueEspaceDo3,
  'conseilPratiqueEspaceDont1': (l) => l.conseilPratiqueEspaceDont1,
  'conseilPratiqueEspaceDont2': (l) => l.conseilPratiqueEspaceDont2,
  // ── conseilEmotionAngry ───────────────────────────────────────────────
  'conseilEmotionAngryDo1': (l) => l.conseilEmotionAngryDo1,
  'conseilEmotionAngryDo2': (l) => l.conseilEmotionAngryDo2,
  'conseilEmotionAngryDo3': (l) => l.conseilEmotionAngryDo3,
  'conseilEmotionAngryDont1': (l) => l.conseilEmotionAngryDont1,
  'conseilEmotionAngryDont2': (l) => l.conseilEmotionAngryDont2,
  // ── conseilEmotionSad ─────────────────────────────────────────────────
  'conseilEmotionSadDo1': (l) => l.conseilEmotionSadDo1,
  'conseilEmotionSadDo2': (l) => l.conseilEmotionSadDo2,
  'conseilEmotionSadDo3': (l) => l.conseilEmotionSadDo3,
  'conseilEmotionSadDont1': (l) => l.conseilEmotionSadDont1,
  'conseilEmotionSadDont2': (l) => l.conseilEmotionSadDont2,
  // ── conseilEmotionNervous ─────────────────────────────────────────────
  'conseilEmotionNervousDo1': (l) => l.conseilEmotionNervousDo1,
  'conseilEmotionNervousDo2': (l) => l.conseilEmotionNervousDo2,
  'conseilEmotionNervousDo3': (l) => l.conseilEmotionNervousDo3,
  'conseilEmotionNervousDont1': (l) => l.conseilEmotionNervousDont1,
  'conseilEmotionNervousDont2': (l) => l.conseilEmotionNervousDont2,
  // ── conseilEmotionTired ───────────────────────────────────────────────
  'conseilEmotionTiredDo1': (l) => l.conseilEmotionTiredDo1,
  'conseilEmotionTiredDo2': (l) => l.conseilEmotionTiredDo2,
  'conseilEmotionTiredDo3': (l) => l.conseilEmotionTiredDo3,
  'conseilEmotionTiredDont1': (l) => l.conseilEmotionTiredDont1,
  'conseilEmotionTiredDont2': (l) => l.conseilEmotionTiredDont2,
  // ── conseilEmotionHappy ───────────────────────────────────────────────
  'conseilEmotionHappyDo1': (l) => l.conseilEmotionHappyDo1,
  'conseilEmotionHappyDo2': (l) => l.conseilEmotionHappyDo2,
  'conseilEmotionHappyDo3': (l) => l.conseilEmotionHappyDo3,
  'conseilEmotionHappyDont1': (l) => l.conseilEmotionHappyDont1,
  'conseilEmotionHappyDont2': (l) => l.conseilEmotionHappyDont2,
  // ── conseilEmotionCalm ────────────────────────────────────────────────
  'conseilEmotionCalmDo1': (l) => l.conseilEmotionCalmDo1,
  'conseilEmotionCalmDo2': (l) => l.conseilEmotionCalmDo2,
  'conseilEmotionCalmDo3': (l) => l.conseilEmotionCalmDo3,
  'conseilEmotionCalmDont1': (l) => l.conseilEmotionCalmDont1,
  'conseilEmotionCalmDont2': (l) => l.conseilEmotionCalmDont2,
  // ── conseilEmotionDynamic ─────────────────────────────────────────────
  'conseilEmotionDynamicDo1': (l) => l.conseilEmotionDynamicDo1,
  'conseilEmotionDynamicDo2': (l) => l.conseilEmotionDynamicDo2,
  'conseilEmotionDynamicDo3': (l) => l.conseilEmotionDynamicDo3,
  'conseilEmotionDynamicDont1': (l) => l.conseilEmotionDynamicDont1,
  'conseilEmotionDynamicDont2': (l) => l.conseilEmotionDynamicDont2,
};
