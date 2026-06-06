---
name: design-system
description: Thème canonique DIGIHARMONY (Navy & Halo) — couleurs, typo, espacement, garde-fous
argument-hint: N/A
scope: all
---

# Design System — DIGIHARMONY « Navy & Halo »

> **Source de vérité visuelle de tous les écrans.** Mode **foncé uniquement**.
> Ambiance : apaisant, bienveillant, sobre, non anxiogène (public ado mineur).
> Implémentation Flutter : `apps/digiharmony_app/lib/theme/theme.dart` (`AppColors` + `AppTheme`).

## Couleurs — chrome

| Rôle | Hex | Usage |
|---|---|---|
| Fond | `#1F2C49` | Fond principal (navy du logo) |
| Fond profond | `#16213C` | Splash, variantes immersives |
| Surface | `#283A5E` | Cartes, blocs, conseil du jour |
| Primaire (cyan) | `#3FB8E6` | Titres, accents, actions, icônes actives |
| Primaire clair | `#8FD8F0` | États secondaires, ondes, soulignés |
| Accent or | `#E0B24A` | Lignes orbitales, accents fins |
| Texte | `#F2F6FB` | Texte clair sur fond foncé |
| Texte atténué | `#A7B6CE` | Sous-titres, légendes, placeholders |

**Dégradé signature :** `#3FB8E6` → `#A8D24E` → `#F0C84A` (cyan → lime → or).
Réservé aux **moments de marque** (splash, halo). **Jamais** sur un écran de journal (collision avec les couleurs d'émotion).

## Couleurs — émotions (catégorielles, RÉSERVÉES au codage des 7 émotions)

> Jamais réutilisées pour le chrome ou le sémantique. Application : fond carré/pastille derrière l'émoticône.

| Émotion (clé) | Hex | Couleur |
|---|---|---|
| Colère / `angry` | `#E5392B` | rouge |
| Joie / `happy` | `#F4C20D` | jaune |
| Dynamique / `dynamic` | `#F57C1F` | orange |
| Tristesse / `sad` | `#3B6FE0` | bleu |
| Nerveux / `nervous` | `#8A3FD1` | violet |
| Calme / `calm` | `#2FAE5F` | vert |
| Fatigue / `tired` | `#8A93A6` | gris |

Sémantiques : Info = réutilise le cyan primaire ; Succès = vert dédié distinct du « calme » ; Alerte = strict nécessaire, maniée avec retenue.

## Typographie

- **DM Sans** : titres gras en cyan primaire, corps ~16 sp clair sur foncé.
- **Serif italique** réservé au **contenu** éditorial des cartes conseils (décoratif, jamais pour l'UI ; prudence grec/cyrillique).
- i18n : 8 alphabets (latin, grec, macédonien/cyrillique) ; titres 2-3 lignes max sans troncature ; aucun texte fixé en largeur ; tester mots longs (grec, roumain).

## Espacement & rayons

- Espacement : `4 / 8 / 16 / 24 / 32`.
- Rayons : cartes/bulles ~`24` ; boutons ~`12` (esthétique « bulle »).

## Composants & règles transverses

- **Toolbar haute** (retour · logo · menu) présente partout **sauf splash et accueil** ; retour masqué si pas d'historique.
- Iconographie : line-art néon cyan ; émoticônes pleines couleur pour les 7 émotions.

## Accessibilité

- Contraste AA (texte clair sur navy) ; vérifier émotions claires (joie/jaune, fatigue/gris).
- Taille de tap 48×48 dp min. Feedback : `HapticFeedback` + son léger ; retour visuel sur chaque tap.
- Ton bienveillant systématique ; jamais d'alerte agressive.

## Animations / micro-interactions

Esprit **doux et subtil** (jamais accrocheur — cf. garde-fous éthiques). Couche réutilisable
`lib/common/anim/` ; intensité **centralisée** dans `anim_constants.dart` (réglage global en 1 fichier).

- **Helpers** : `EntreeDouce` (cascade fondu + glissement ~8 px à l'apparition), `routeDouce` (transitions
  de page fondu + léger glissement), `TapAnime` (surface tappable = scale 0.97 + `HapticFeedback`, **ripple
  supprimé**, focus/sémantique conservés), `CompteurAnime` (count-up). Crossfade d'états via `AnimatedSwitcher`.
- **RÈGLE D'OR a11y** : **toute** animation est **no-op si `MediaQuery.disableAnimations`** (reduced-motion)
  → état final immédiat. Et **animations FINIES** (jamais infinies hors halos/particules dédiés, eux aussi
  RM-aware) → piège `pumpAndSettle` évité (tests : `disableAnimations:true` + `pump(Duration)`). Voir rule
  `3-flutter-animations-a11y-finite` + [[testing]].
- **Tap** : scale + haptique **sans ripple Material** (jugé trop dur pour l'esthétique douce). Boutons
  Material standards conservés tels quels ; pastilles d'humeur / deck Conseils gardent leurs anims propres.
- Halo respirant + particules flottantes (ambiantes) restent les seules animations en boucle, déjà RM-aware.

## Principe ludique apaisant — garde-fous éthiques (NON négociables)

Vivant mais **jamais accrocheur**. **Aucun streak, aucun point/badge/classement/comparaison, aucun rappel agressif/FOMO, aucune boucle de rétention.** Pas de mascotte. L'app combat la sur-sollicitation. Voir [[architecture]] et DEC-003.
