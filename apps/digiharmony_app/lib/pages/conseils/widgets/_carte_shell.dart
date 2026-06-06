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

/// Renvoie l'icône Material associée à la clé de carte [cle].
///
/// Chaque carte possède son propre tag visuel (icône + libellé). Le défaut
/// est [Icons.lightbulb_outline] pour toute clé inconnue.
IconData iconeTagPourCle(String cle) {
  return _iconesTag[cle] ?? Icons.lightbulb_outline;
}

// Table icône → clé de carte. Une entrée par carte ayant un tag spécifique.
const Map<String, IconData> _iconesTag = {
  'tipDay01': Icons.air,
  'tipDay02': Icons.bolt,
  'tipDay03': Icons.volunteer_activism_outlined,
  'tipDay04': Icons.park_outlined,
  'tipDay05': Icons.do_not_disturb_on_outlined,
  'tipDay06': Icons.sentiment_satisfied_alt,
  'tipDay07': Icons.spa_outlined,
  'conseilRappelPresent': Icons.center_focus_strong_outlined,
  'conseilRappelLikes': Icons.star_outline,
  'conseilPratiqueInteractions': Icons.groups_outlined,
  'conseilPratiqueEspace': Icons.crop_free,
};

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
  'tipDay01Tag': (l) => l.conseilsTagRespiration,
  'tipDay01Citation1': (l) => l.tipDay01,
  'tipDay01Citation2': (_) => '',
  'tipDay01SousTexte': (_) => '',
  'tipDay01Do1': (l) => l.tipDay01Do1,
  'tipDay01Do2': (l) => l.tipDay01Do2,
  'tipDay01Do3': (l) => l.tipDay01Do3,
  'tipDay01Dont1': (l) => l.tipDay01Dont1,
  'tipDay01Dont2': (l) => l.tipDay01Dont2,
  'tipDay02Tag': (l) => l.conseilsTagEnergie,
  'tipDay02Citation1': (l) => l.tipDay02,
  'tipDay02Citation2': (_) => '',
  'tipDay02SousTexte': (_) => '',
  'tipDay02Do1': (l) => l.tipDay02Do1,
  'tipDay02Do2': (l) => l.tipDay02Do2,
  'tipDay02Do3': (l) => l.tipDay02Do3,
  'tipDay02Dont1': (l) => l.tipDay02Dont1,
  'tipDay02Dont2': (l) => l.tipDay02Dont2,
  'tipDay03Tag': (l) => l.conseilsTagGratitude,
  'tipDay03Citation1': (l) => l.tipDay03,
  'tipDay03Citation2': (_) => '',
  'tipDay03SousTexte': (_) => '',
  'tipDay03Do1': (l) => l.tipDay03Do1,
  'tipDay03Do2': (l) => l.tipDay03Do2,
  'tipDay03Do3': (l) => l.tipDay03Do3,
  'tipDay03Dont1': (l) => l.tipDay03Dont1,
  'tipDay03Dont2': (l) => l.tipDay03Dont2,
  'tipDay04Tag': (l) => l.conseilsTagGrandAir,
  'tipDay04Citation1': (l) => l.tipDay04,
  'tipDay04Citation2': (_) => '',
  'tipDay04SousTexte': (_) => '',
  'tipDay04Do1': (l) => l.tipDay04Do1,
  'tipDay04Do2': (l) => l.tipDay04Do2,
  'tipDay04Do3': (l) => l.tipDay04Do3,
  'tipDay04Dont1': (l) => l.tipDay04Dont1,
  'tipDay04Dont2': (l) => l.tipDay04Dont2,
  'tipDay05Tag': (l) => l.conseilsTagDeconnexion,
  'tipDay05Citation1': (l) => l.tipDay05,
  'tipDay05Citation2': (_) => '',
  'tipDay05SousTexte': (_) => '',
  'tipDay05Do1': (l) => l.tipDay05Do1,
  'tipDay05Do2': (l) => l.tipDay05Do2,
  'tipDay05Do3': (l) => l.tipDay05Do3,
  'tipDay05Dont1': (l) => l.tipDay05Dont1,
  'tipDay05Dont2': (l) => l.tipDay05Dont2,
  'tipDay06Tag': (l) => l.conseilsTagLien,
  'tipDay06Citation1': (l) => l.tipDay06,
  'tipDay06Citation2': (_) => '',
  'tipDay06SousTexte': (_) => '',
  'tipDay06Do1': (l) => l.tipDay06Do1,
  'tipDay06Do2': (l) => l.tipDay06Do2,
  'tipDay06Do3': (l) => l.tipDay06Do3,
  'tipDay06Dont1': (l) => l.tipDay06Dont1,
  'tipDay06Dont2': (l) => l.tipDay06Dont2,
  'tipDay07Tag': (l) => l.conseilsTagBienveillance,
  'tipDay07Citation1': (l) => l.tipDay07,
  'tipDay07Citation2': (_) => '',
  'tipDay07SousTexte': (_) => '',
  'tipDay07Do1': (l) => l.tipDay07Do1,
  'tipDay07Do2': (l) => l.tipDay07Do2,
  'tipDay07Do3': (l) => l.tipDay07Do3,
  'tipDay07Dont1': (l) => l.tipDay07Dont1,
  'tipDay07Dont2': (l) => l.tipDay07Dont2,
  // ── conseilRappelPresent ──────────────────────────────────────────────
  'conseilRappelPresentTag': (l) => l.conseilsTagPresence,
  'conseilRappelPresentCitation1': (l) => l.conseilRappelPresentCitation1,
  'conseilRappelPresentCitation2': (l) => l.conseilRappelPresentCitation2,
  'conseilRappelPresentSousTexte': (l) => l.conseilRappelPresentSousTexte,
  'conseilRappelPresentDo1': (l) => l.conseilRappelPresentDo1,
  'conseilRappelPresentDo2': (l) => l.conseilRappelPresentDo2,
  'conseilRappelPresentDo3': (l) => l.conseilRappelPresentDo3,
  'conseilRappelPresentDont1': (l) => l.conseilRappelPresentDont1,
  'conseilRappelPresentDont2': (l) => l.conseilRappelPresentDont2,
  // ── conseilRappelLikes ────────────────────────────────────────────────
  'conseilRappelLikesTag': (l) => l.conseilsTagEstimeDeSoi,
  'conseilRappelLikesCitation1': (l) => l.conseilRappelLikesCitation1,
  'conseilRappelLikesCitation2': (l) => l.conseilRappelLikesCitation2,
  'conseilRappelLikesSousTexte': (l) => l.conseilRappelLikesSousTexte,
  'conseilRappelLikesDo1': (l) => l.conseilRappelLikesDo1,
  'conseilRappelLikesDo2': (l) => l.conseilRappelLikesDo2,
  'conseilRappelLikesDo3': (l) => l.conseilRappelLikesDo3,
  'conseilRappelLikesDont1': (l) => l.conseilRappelLikesDont1,
  'conseilRappelLikesDont2': (l) => l.conseilRappelLikesDont2,
  // ── conseilPratiqueInteractions ───────────────────────────────────────
  'conseilPratiqueInteractionsTag': (l) => l.conseilsTagRelations,
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
  'conseilPratiqueEspaceTag': (l) => l.conseilsTagEspace,
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
