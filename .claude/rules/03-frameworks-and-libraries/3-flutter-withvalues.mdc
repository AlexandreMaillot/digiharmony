---
description: APPLIQUER withValues au lieu de withOpacity LORS de la modification d'opacité des couleurs
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

Principe:

- withOpacity() est déprécié dans Flutter
- Utiliser withValues(alpha: ) à la place
- Améliorer la compatibilité avec les futures versions de Flutter
- Appliquer sur toutes les modifications d'opacité de couleur

Règle obligatoire:

- INTERDIRE l'utilisation de .withOpacity()
- TOUJOURS utiliser .withValues(alpha: ) pour modifier l'opacité

Syntaxe de remplacement:

- Ancien: color.withOpacity(valeur)
- Nouveau: color.withValues(alpha: valeur)

Cas d'utilisation:

- Container avec fond semi-transparent
- Bordures avec transparence
- Text avec couleur transparente
- Icônes avec opacité
- Backgrounds avec overlay

Valeurs alpha:

- Entre 0.0 (transparent) et 1.0 (opaque)
- Utiliser des valeurs décimales explicites
- Valeurs courantes: 0.1, 0.3, 0.5, 0.6, 0.8

Exemples corrects:

```dart
// Container avec fond semi-transparent
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.primary.withValues(alpha: 0.1),
  ),
)

// Bordure avec transparence
Border.all(
  color: theme.colorScheme.error.withValues(alpha: 0.3),
)

// Text avec couleur transparente
Text(
  'Mon texte',
  style: TextStyle(
    color: Colors.black.withValues(alpha: 0.6),
  ),
)

// Icon avec opacité
Icon(
  Icons.check,
  color: Colors.green.withValues(alpha: 0.8),
)
```

Exemples interdits:

```dart
// ❌ Ne pas utiliser withOpacity (déprécié)
color: Colors.blue.withOpacity(0.5)
color: theme.colorScheme.primary.withOpacity(0.3)
backgroundColor: Colors.red.withOpacity(0.8)
```

Migration du code existant:

- Rechercher tous les .withOpacity(
- Remplacer par .withValues(alpha:
- Vérifier le rendu visuel
- Tester sur iOS et Android

Avantages:

- Code à jour avec les dernières versions de Flutter
- Meilleure performance
- Compatibilité future garantie
- API plus explicite et claire
