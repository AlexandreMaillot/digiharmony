# Decision: Design system unique « Navy & Halo », mode foncé, palette émotions cloisonnée

| Field   | Value                |
| ------- | -------------------- |
| ID      | DEC-003              |
| Date    | 2026-06-05           |
| Feature | Thème / design system |
| Status  | Accepted             |

## Context

Tous les écrans doivent partager une identité visuelle cohérente, apaisante et non
anxiogène (public ado mineur, Erasmus+). Le scaffold VGV n'a aucun `ThemeData` custom.
Un thème canonique (« Navy & Halo ») a été fourni, aligné sur le logo et les maquettes Banani.

## Decision

Adopter un **design system unique, mode foncé uniquement**, matérialisé dans
`apps/digiharmony_app/lib/theme/theme.dart` (`AppColors` + `AppTheme`) et documenté dans
[[design-system]] (mémoire = source de vérité). Règles structurantes :

- **Palette chrome** centralisée (fond `#1F2C49`, fond profond splash `#16213C`, surface
  `#283A5E`, primaire cyan `#3FB8E6`, primaire clair `#8FD8F0`, accent or `#E0B24A`,
  texte `#F2F6FB` / atténué `#A7B6CE`).
- **Dégradé signature** `#3FB8E6 → #A8D24E → #F0C84A` réservé aux moments de marque
  (splash, halo), **jamais** sur le journal.
- **Palette des 7 émotions cloisonnée** : réservée au codage émotionnel, jamais réutilisée
  pour le chrome ou le sémantique.
- Typo **DM Sans** ; espacement `4/8/16/24/32` ; rayons cartes ~`24` / boutons ~`12`.
- **Garde-fous éthiques** : aucun streak/point/badge/classement, aucun rappel FOMO, aucune
  boucle de rétention.

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Thème par écran (couleurs en dur) | rapide à court terme | dérive visuelle, doublons | incohérence + double travail |
| Material 3 par défaut | zéro effort | hors identité de marque | ne reflète pas « Navy & Halo » |
| Mode clair + foncé | flexibilité | non demandé, surcharge | l'identité est foncée uniquement |

## Consequences

- ✅ Cohérence visuelle, un seul point de changement (`theme.dart`).
- ✅ Couleurs d'émotion isolées → pas de collision sémantique dans le journal.
- ✅ Splash conserve le fond profond `#16213C`, le reste de l'app sur `#1F2C49`.
- ⚠️ Police DM Sans + logos à vendorer dans `assets/` (sinon fallback non bloquant).
- ⚠️ Toolbar haute présente partout **sauf** splash et accueil.
