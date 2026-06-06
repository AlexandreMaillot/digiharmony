---
description: DÉSACTIVER le checkmark par défaut sur un `FilterChip`/`ChoiceChip` quand un `avatar` est fourni — ils se superposent
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

# Règle : `showCheckmark: false` obligatoire quand `avatar` est fourni

## Contexte

Par défaut, `FilterChip` et `ChoiceChip` affichent un **checkmark** à gauche quand `selected: true`. Si l'appelant fournit **aussi** un `avatar` (Icon, CircleAvatar, etc.), les deux se **superposent** dans la même zone → rendu visuel cassé (checkmark "sur" l'icône, illisible).

La doc Flutter ne l'explicite pas dans la signature — facile de rater au premier rendu statique (chip non sélectionné = pas de checkmark = bug invisible). Le bug apparaît seulement quand l'état bascule à `selected: true`.

## ❌ Interdit

```dart
FilterChip(
  label: Text('Afficher les archivés'),
  selected: afficherArchives,
  onSelected: (v) => bloc.add(AfficherArchivesChange(v)),
  avatar: Icon(Icons.archive), // ❌ checkmark se superpose à l'icône
)
```

## ✅ Obligatoire

```dart
FilterChip(
  label: Text('Afficher les archivés'),
  selected: afficherArchives,
  onSelected: (v) => bloc.add(AfficherArchivesChange(v)),
  showCheckmark: false,  // ← obligatoire quand `avatar` est défini
  avatar: Icon(
    afficherArchives ? Icons.archive : Icons.archive_outlined,
  ),
)
```

## Comment signaler l'état sélectionné (sans checkmark)

Avec `showCheckmark: false`, l'état `selected: true` reste clair via 3 signaux combinés — tous gérés par le thème Material :

1. **Icône filled vs outlined** — ex. `Icons.archive` (plein) quand sélectionné, `Icons.archive_outlined` (contour) sinon. Explicite côté appelant.
2. **Fond du chip** — `secondaryContainer` en sélectionné, `surface` sinon (gérés automatiquement par `ThemeData.chipTheme`).
3. **Texte + icône colorés** — `onSecondaryContainer` en sélectionné vs `onSurfaceVariant` sinon.

## Quand un `avatar` n'est PAS fourni

Garder le checkmark par défaut est correct — il joue son rôle de feedback visuel :

```dart
FilterChip(
  label: Text('Actif'),
  selected: estActif,
  onSelected: (v) => bloc.add(FiltreStatutChange(v)),
  // Pas d'avatar → checkmark OK par défaut
)
```

## Cas `ChoiceChip`

Même règle, même symptôme — pattern déjà appliqué dans `nouvelle_course` (chips prestation / jour semaine avec icônes).

## Détection d'une occurence

Grep rapide pour trouver les combos problématiques :

```bash
grep -rn "FilterChip\|ChoiceChip" lib/ -A 5 | grep -B 2 "avatar:" | grep -L "showCheckmark: false"
```

Si un `avatar:` apparaît sans `showCheckmark: false` à proximité, le bug visuel est présent dès que le chip passe en sélectionné.
