---
description: Ne JAMAIS filtrer en query Firestore `where('champ', isEqualTo: <valeurParDéfaut>)` sur un champ optionnel ajouté tardivement. L'égalité Firestore EXCLUT les documents qui n'ont pas le champ (legacy) — même ceux dont le modèle leur attribuerait cette valeur par défaut côté client. Filtrer côté projection/client à la place.
globs:
  - "apps/**/lib/**/depots/**/*.dart"
  - "apps/**/lib/**/*depot*.dart"
  - "packages/**/lib/**/*.dart"
alwaysApply: false
---

# Firestore — filtrer un champ optionnel/legacy côté projection, pas en query

## Pourquoi

Une query `where('sens', isEqualTo: 'aller')` ne renvoie **que** les docs qui
ont explicitement `sens == 'aller'`. Les docs **sans** le champ (créés avant son
ajout) sont **silencieusement exclus** — alors même que le modèle les hydrate
avec la valeur par défaut `'aller'`. Résultat : des données legacy disparaissent
de l'UI sans erreur ni log.

Vécu (DEC-113, 2026-05-22) : filtrer les horaires navette par `sens` en query
aurait masqué tous les horaires aller créés avant l'ajout du champ `sens`.

## Règle

Pour un champ **optionnel / ajouté tardivement** qui a une **valeur par défaut**
côté modèle (`(data['x'] as T?) ?? défaut`) :

1. **NE PAS** le filtrer via `where(champ == défaut)` dans la query Firestore.
2. **Filtrer côté projection client**, après hydratation, en s'appuyant sur le
   défaut du modèle (`if (model.champ == valeurNonVoulue) continue;`).
3. Filtrer en query reste OK pour une valeur **non-défaut** explicitement écrite
   partout (ex. `where('sens', ==, 'retour')` pour un sous-stream ciblé), car on
   veut justement exclure aussi les legacy.

## Anti-pattern

```dart
// ❌ exclut les horaires legacy sans champ `sens`
.where('jour_semaine', isEqualTo: jour)
.where('sens', isEqualTo: 'aller') // legacy (sans le champ) → disparaissent
```

## Bon pattern

```dart
// ✅ query sans filtre sens ; exclusion côté projection (legacy = aller)
for (final horaire in horaires) {
  if (horaire.sens == kSensRetourClient) continue; // défaut modèle = aller
  // ...
}
```
