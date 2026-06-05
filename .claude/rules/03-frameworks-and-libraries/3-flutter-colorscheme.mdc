---
description: APPLIQUER les propriétés actuelles du ColorScheme LORS de l'utilisation de couleurs du thème Flutter
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

Principe:
- Utiliser les propriétés actuelles du ColorScheme de Flutter
- Éviter les propriétés dépréciées pour éviter les warnings
- Suivre les nouvelles conventions Material Design 3

Propriétés dépréciées à remplacer:

Surface variants (Material Design 3):
- ❌ `theme.colorScheme.surfaceVariant` → ✅ `theme.colorScheme.surfaceContainerHighest`
- ❌ `theme.colorScheme.onSurfaceVariant` → ✅ `theme.colorScheme.onSurface`
- ❌ `theme.colorScheme.background` → ✅ `theme.colorScheme.surface`
- ❌ `theme.colorScheme.onBackground` → ✅ `theme.colorScheme.onSurface`

Propriétés de surface actuelles (Material Design 3):
- `theme.colorScheme.surface` - Surface de base
- `theme.colorScheme.surfaceDim` - Surface atténuée
- `theme.colorScheme.surfaceBright` - Surface lumineuse
- `theme.colorScheme.surfaceContainerLowest` - Conteneur le plus bas
- `theme.colorScheme.surfaceContainerLow` - Conteneur bas
- `theme.colorScheme.surfaceContainer` - Conteneur standard
- `theme.colorScheme.surfaceContainerHigh` - Conteneur haut
- `theme.colorScheme.surfaceContainerHighest` - Conteneur le plus haut

Règles strictes:
- INTERDIRE l'utilisation de `surfaceVariant` et `onSurfaceVariant`
- TOUJOURS utiliser `surfaceContainerHighest` et `onSurface` à la place
- INTERDIRE l'utilisation de `background` et `onBackground`
- Utiliser la hiérarchie de surfaces appropriée au contexte

Exemples corrects:
```dart
// Container avec fond
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.surfaceContainerHighest,
  ),
)

// Card avec couleur de surface
Card(
  color: theme.colorScheme.surfaceContainer,
)

// Surface atténuée
Container(
  color: theme.colorScheme.surfaceDim,
)

// Surface lumineuse
Container(
  color: theme.colorScheme.surfaceBright,
)
```

Exemples interdits:
```dart
// ❌ Ne pas utiliser surfaceVariant (déprécié)
Container(
  color: theme.colorScheme.surfaceVariant,
)

// ❌ Ne pas utiliser background (déprécié)
Container(
  color: theme.colorScheme.background,
)

// ❌ Ne pas utiliser onBackground (déprécié)
Text(
  'Mon texte',
  style: TextStyle(color: theme.colorScheme.onBackground),
)
```

Migration obligatoire:
```dart
// Ancien → Nouveau
theme.colorScheme.surfaceVariant → theme.colorScheme.surfaceContainerHighest
theme.colorScheme.onSurfaceVariant → theme.colorScheme.onSurface
theme.colorScheme.background → theme.colorScheme.surface
theme.colorScheme.onBackground → theme.colorScheme.onSurface
```

Hiérarchie de surfaces (du plus bas au plus haut):
1. `surface` - Surface de base
2. `surfaceDim` - Légèrement atténuée
3. `surfaceContainerLowest` - Conteneur très subtil
4. `surfaceContainerLow` - Conteneur subtil
5. `surfaceContainer` - Conteneur standard
6. `surfaceContainerHigh` - Conteneur élevé
7. `surfaceContainerHighest` - Conteneur le plus élevé
8. `surfaceBright` - Surface la plus lumineuse

Bonnes pratiques:
- Utiliser la hiérarchie de surfaces pour créer de la profondeur
- Choisir le niveau approprié selon l'élévation visuelle souhaitée
- Tester l'apparence en mode clair et sombre
- Documenter le choix de surface dans les composants complexes
- Suivre les guidelines Material Design 3 pour la cohérence

Avantages:
- Compatibilité avec Material Design 3
- Pas de warnings de dépréciation
- Meilleure gestion des thèmes clair/sombre
- Hiérarchie visuelle plus claire
- Support à long terme garanti
