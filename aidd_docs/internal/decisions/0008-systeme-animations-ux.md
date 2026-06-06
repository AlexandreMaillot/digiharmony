# Decision: Système d'animations UX (douces, centralisées, a11y-aware)

| Field   | Value                       |
| ------- | --------------------------- |
| ID      | DEC-008                     |
| Date    | 2026-06-07                  |
| Feature | Micro-animations UX (app-wide) |
| Status  | Accepted                    |

## Context

L'app manquait de micro-animations : apparitions abruptes, navigation sèche, états (chargement→contenu)
qui « sautent ». Objectif : rendre l'expérience plus vivante **sans trahir l'esprit doux/apaisant** (public
mineur, garde-fous anti-rétention DEC-003) et **sans casser l'a11y ni les tests** (reduced-motion +
piège `pumpAndSettle` sur animations infinies).

## Decision

Introduire une **couche d'animations réutilisable** `lib/common/anim/` avec **intensité centralisée**
(`anim_constants.dart`), appliquée app-wide :

- `EntreeDouce` — cascade fondu + glissement (~8 px, ~400 ms, décalage ~70 ms) à l'apparition des items.
- `routeDouce<T>()` — transitions de page fondu + léger glissement (toutes les routes `AppRouter`).
- `TapAnime` — surface tappable : scale 0.97 + `HapticFeedback`, **ripple Material supprimé**, `InkWell`
  conservé dessous (focus clavier, Semantics, cible ≥48 dp).
- `CompteurAnime` — count-up des chiffres (jauge Temps d'écran, etc.).
- `AnimatedSwitcher` — crossfade chargement→contenu (Journal, Conseils, Temps d'écran).

## Invariants (non négociables)

- **Reduced-motion** (`MediaQuery.disableAnimations`) → **toute** animation no-op (état final immédiat).
- **Animations FINIES** ; seules ambiances en boucle = `HaloRespirant` / `ParticulesFlottantes` (déjà
  RM-aware). → règle `3-flutter-animations-a11y-finite`, [[testing]] (jamais `pumpAndSettle` sur infini).
- Subtilité : pas de signal accrocheur ; conforme garde-fous éthiques (DEC-003).

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Garder le ripple Material au tap | standard | trop « dur » sur le thème doux ; double feedback si combiné au scale | esthétique + redondance |
| Animations par écran, ad hoc | rapide localement | divergence, intensité non réglable globalement | non maintenable |
| Animer aussi Demarrage/Bienvenue | cohérence totale | ces écrans ont déjà halos/particules infinis ; risque de régression tests | gain faible / risque élevé |

## Consequences

- ✅ Réglage global de l'intensité en **1 fichier** (`anim_constants.dart`).
- ✅ `flutter analyze` 0 issue ; suite verte (helpers testés : no-op reduced-motion + état final sans hang).
- ⚠️ Périmètre tap = surfaces `InkWell` custom ; boutons Material standards et widgets à anim propre
  (pastilles d'humeur, deck Conseils, PiluleAction breathing) **non convertis** (anim déjà spécifique).
- ⚠️ Entrée non appliquée au contenu Temps d'écran (jauge complexe — crossfade d'état compense).
- 🔗 `design-system.md` (section Animations), rule `3-flutter-animations-a11y-finite`. [[architecture]].
