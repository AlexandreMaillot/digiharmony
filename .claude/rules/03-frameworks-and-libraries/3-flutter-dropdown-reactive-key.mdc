---
description: APPLIQUER cette règle LORS de l'utilisation de DropdownButtonFormField dont la valeur est pilotée par un Bloc
globs: apps/*/lib/**/widgets/select_*.dart, apps/*/lib/**/widgets/*dropdown*.dart, apps/*/lib/core/widgets/select_*.dart
alwaysApply: true
---

`DropdownButtonFormField.initialValue` est statique : sans clé qui change avec la valeur, le widget garde son state interne et ignore les nouvelles valeurs émises par le Bloc.

**Règle obligatoire** : déclarer `key: ValueKey<Object?>(valeur)` sur le `DropdownButtonFormField` chaque fois que la valeur est dérivée d'un Bloc/state externe.

```dart
DropdownButtonFormField<T>(
  key: ValueKey<Object?>(valeur),  // ← obligatoire si valeur vient d'un bloc
  initialValue: valeur,
  items: ...,
  onChanged: (v) => bloc.add(...),
)
```

**Quand l'omission casse l'UX** :
- Bloc avec défaut UI appliqué post-construction (ex. `filtreDate: aujourdhui` si `filtreInitial == null`)
- Re-souscription stream après reset filtres
- Synchronisation cross-widget (ex. clic externe qui change la sélection)

**Quand l'omission est tolérable** :
- Dropdown 100% local (pas piloté par bloc) — préférer `StatefulWidget` avec controller
- Valeur statique connue à la 1re construction (typiquement formulaires figés)

**Référence** : DEC-027 — `DropdownButtonFormField` réactif via `ValueKey(valeur)`. Vécu : filtre Date courses taxi affichait vide malgré bloc émettant `aujourdhui`.

**Anti-pattern à proscrire** : ajouter une `GlobalKey<FormFieldState>` partagée pour `didChange` manuel — boilerplate massif, casse le pattern Bloc.
