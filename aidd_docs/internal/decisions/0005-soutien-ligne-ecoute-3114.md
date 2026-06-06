# Decision: Soutien — ligne d'écoute = 3114 (donnée réelle FR), fallback FR temporaire

| Field   | Value                       |
| ------- | --------------------------- |
| ID      | DEC-005                     |
| Date    | 2026-06-06                  |
| Feature | Écran de soutien (Super conseil) |
| Status  | Accepted                    |

## Context

L'écran de soutien (public **mineur**, Erasmus+) propose une « ligne d'écoute ». Par défaut
`tableRessources` était **vide** : aucun numéro réel codé tant que les partenaires ne valident pas
(garde-fou DEC-SO-007). Décision produit : intégrer le **3114** (Numéro national de prévention du
suicide, France — gratuit, 24h/24) comme **donnée réelle validée pour la locale FR**.

## Decision

`tableRessources['fr']` = `RessourceLigneEcoute(nom: "Ligne d'écoute", cible: '3114',
disponibilite: 'Disponible 24h/24')` — **donnée réelle** (pas un placeholder). **Fallback FR** pour
toute locale sans entrée propre (temporaire). Bloc redessiné (carte tappable : icône ☎ + libellé +
`tel:` via `url_launcher`). Nouveau token **`AppColors.vertAppel` (`0xFF34C759`)** pour l'action
d'appel — distinct de `MoodColors` (palette émotions interdite hors journal). Garde-fous recalibrés :
SO-RES-3 impose `fr.cible == '3114'`, tout **autre** vrai numéro reste interdit (ARB + sources Dart).

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Table vide jusqu'à validation partenaires | sûr, zéro numéro | écran sans ressource d'appel | 3114 est officiel + déjà validé |
| Numéro par pays dès maintenant | correct géographiquement | numéros non encore fournis | hors périmètre immédiat |
| Réutiliser `MoodColors.calm` (vert) | pas de nouveau token | viole le cloisonnement palette émotions | token dédié requis |

## Consequences

- ✅ Bouton d'appel fonctionnel (`tel:3114`) sur l'écran soutien.
- ✅ Garde-fou maintenu contre tout autre vrai numéro hardcodé.
- ⚠️ **3114 ne fonctionne qu'en France** : montré en fallback à toutes les langues = **temporaire**.
  `// TODO(partenaires)` : ajouter un numéro **validé par pays/locale** (le fallback FR disparaîtra
  pour les locales renseignées).
- 🔗 [[design-system]] (token chrome vs palette émotions), [[architecture]] (compteur Drift dérivé →
  déclenchement soutien).
