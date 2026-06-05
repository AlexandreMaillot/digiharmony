---
description: APPLIQUER une extension avec getters booléens LORS de la création d'un enum de status
globs: apps/*/lib/**/*_state.dart
alwaysApply: true
---

Principe:
- Créer une extension pour chaque enum de status ou état
- Ajouter un getter booléen par valeur de l'enum
- Améliorer la lisibilité et l'expressivité du code
- Faciliter l'autocomplétion

Nommage des getters:
- Préfixer avec `est` pour les états (estInitial, estEnChargement)
- Préfixer avec `a` pour les propriétés (aDesErreurs, aDesResultats)
- Utiliser des verbes d'état explicites
- Éviter les abréviations

Convention de nommage extension:
- Suffixer le nom de l'enum avec X (ex: MonStatusX)
- Placer l'extension dans le même fichier que l'enum
- Documenter si nécessaire

Structure type:
```dart
enum MonStatus {
  initial,
  chargement,
  succes,
  vide,
  erreur,
}

extension MonStatusX on MonStatus {
  bool get estInitial => this == MonStatus.initial;
  bool get estEnChargement => this == MonStatus.chargement;
  bool get estSucces => this == MonStatus.succes;
  bool get estVide => this == MonStatus.vide;
  bool get estEnErreur => this == MonStatus.erreur;
}
```

Utilisation dans le code:
- Préférer `etat.status.estEnChargement`
- Éviter `etat.status == MonStatus.chargement`
- Combiner avec des opérateurs logiques
- Utiliser dans les conditions if, ternaires, etc.
