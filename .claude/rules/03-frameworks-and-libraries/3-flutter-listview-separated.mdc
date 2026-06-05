---
description: UTILISER ListView.separated au lieu de ListView.builder LORS de la création de listes avec séparateurs
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

Principe:
- Utiliser ListView.separated pour toutes les listes avec séparateurs
- Éviter ListView.builder + Divider manuel dans les items
- Améliorer les performances et la lisibilité du code

Règle absolue:
- ListView.separated pour les listes avec séparateurs automatiques
- ListView.builder uniquement pour les listes sans séparateurs

Structure obligatoire:
```dart
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return MonWidgetItem(item: item);
  },
  separatorBuilder: (context, index) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.outline,
    );
  },
)
```

Exemples corrects:
```dart
// ✅ Correct - ListView.separated
ListView.separated(
  itemCount: actualites.length,
  itemBuilder: (context, index) {
    return ActualiteItem(actualite: actualites[index]);
  },
  separatorBuilder: (context, index) {
    return Divider(height: 1, color: theme.colorScheme.outline);
  },
)

// ✅ Correct - ListView.builder sans séparateurs
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return MonWidget(item: items[index]);
  },
)
```

Exemples interdits:
```dart
// ❌ Incorrect - ListView.builder avec Divider dans l'item
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        MonWidget(item: items[index]),
        Divider(), // Séparateur dans l'item
      ],
    );
  },
)

// ❌ Incorrect - ListView.builder avec séparateurs manuels
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        MonWidget(item: items[index]),
        if (index < items.length - 1) Divider(), // Séparateur conditionnel
      ],
    );
  },
)
```

Avantages de ListView.separated:
- Performance optimisée (séparateurs gérés nativement)
- Code plus propre et lisible
- Séparateurs uniformes automatiquement
- Moins de logique conditionnelle dans les items
- Meilleure gestion de l'espacement

Bonnes pratiques:
- Utiliser shrinkWrap: true pour les ListView imbriquées
- Utiliser physics: NeverScrollableScrollPhysics() pour les ListView dans ScrollView
- Personnaliser les séparateurs via separatorBuilder
- Utiliser des constantes pour les propriétés des Divider
- Tester l'affichage sur différentes tailles d'écran

Cas d'usage:
- Listes d'actualités avec séparateurs
- Listes de contacts avec lignes de séparation
- Listes de produits avec bordures
- Toute liste nécessitant des séparateurs visuels
