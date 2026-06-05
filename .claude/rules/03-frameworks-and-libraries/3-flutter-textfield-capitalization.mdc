---
description: Configurer `textCapitalization` + `autocorrect` + `enableSuggestions` selon la sémantique du champ. Email = `none` + `autocorrect: false` + `enableSuggestions: false` (sinon le clavier mobile met une majuscule auto sur le 1er caractère + propose des corrections qui bricolent la saisie). Nom/Prénom = `words` (1ʳᵉ lettre majuscule par mot) + autocorrect activé. Texte libre = `sentences`.
globs: apps/**/*.dart
alwaysApply: false
---
- **Email / login / username technique** :
  ```dart
  TextField(
    keyboardType: TextInputType.emailAddress,
    textCapitalization: TextCapitalization.none,    // pas de Majuscule auto
    autocorrect: false,                              // pas de correction
    enableSuggestions: false,                        // pas de suggestions
    ...
  )
  ```
  Sinon iOS/Android mettent `M` au lieu de `m` sur le 1er char et corrigent `marie.dupont@gmail.com` en `Marie.Dupont@Gmail.com` côté serveur (les emails normalisent en lowercase mais c'est une mauvaise UX).
- **Nom / Prénom / Ville** : `TextCapitalization.words` (chaque mot capitalisé). `autocorrect: true` (utile pour noms composés type `Saint-Denis`, `de la Croix`).
- **Texte libre / commentaire / note** : `TextCapitalization.sentences` (Material default si non spécifié).
- **Numéro de téléphone / code OTP** : `keyboardType: TextInputType.number` ou `phone` — la capitalisation n'a pas d'effet mais expliciter `none` reste défensif.
- **Hint texts** obligatoires sur les champs profil pour donner un exemple concret :
  - `hintText: 'Ex. Dupont'` (Nom)
  - `hintText: 'ex. marie.dupont@gmail.com'` (Email — placeholder en minuscules cohérent avec la saisie)
- Cas vécu projet (2026-05-09, modal signin OTP step 3) : champ Email avec capitalisation par défaut `sentences` → user tape `marie@gmail.com` mais le clavier insère `Marie@gmail.com`. Email rejeté par regex côté validation client. Fix triple combo `none + autocorrect: false + enableSuggestions: false` cf. DEC-085.
