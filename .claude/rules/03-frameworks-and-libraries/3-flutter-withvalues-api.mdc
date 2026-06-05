---
description: APPLIQUER l'API withValues LORS de la gestion de la transparence des couleurs Flutter
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

API withValues pour la transparence (Flutter 3.27+):
- Utiliser `withValues` au lieu de `withOpacity` pour la gestion de la transparence
- `withOpacity` est déprécié depuis Flutter 3.27+
- `withValues` utilise des paramètres nommés plus explicites et maintenus

Syntaxe correcte:
```dart
// ✅ Correct - Nouvelle API
color.withValues(alpha: 0.5)
color.withValues(alpha: 0.1)
color.withValues(alpha: 0.7)

// ❌ Incorrect - API dépréciée
color.withOpacity(0.5)
color.withOpacity(0.1)
color.withOpacity(0.7)
```

Cas d'usage courants:
- Couleurs de fond avec transparence
- Textes avec opacité réduite
- Overlays et overlays
- Gradients avec transparence
- Bordures semi-transparentes

Exemples pratiques:
```dart
// Fond avec transparence
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.primary.withValues(alpha: 0.1),
  ),
)

// Texte avec opacité
Text(
  'Sous-titre',
  style: textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
  ),
)

// Gradient avec transparence
LinearGradient(
  colors: [
    theme.colorScheme.primary.withValues(alpha: 0.1),
    theme.colorScheme.primary.withValues(alpha: 0.05),
  ],
)

// Overlay semi-transparent
Container(
  color: Colors.black.withValues(alpha: 0.5),
)
```

Migration obligatoire:
```dart
// ❌ Déprécié → ✅ Correct
color.withOpacity(0.5) → color.withValues(alpha: 0.5)
color.withOpacity(0.1) → color.withValues(alpha: 0.1)
color.withOpacity(0.7) → color.withValues(alpha: 0.7)
color.withOpacity(0.3) → color.withValues(alpha: 0.3)
```

Avantages de withValues:
- API plus moderne et maintenue
- Paramètres nommés plus explicites
- Évite les warnings de dépréciation
- Meilleure lisibilité du code
- Compatibilité future garantie
- Performance optimisée

Bonnes pratiques:
- Toujours utiliser `withValues(alpha: value)` au lieu de `withOpacity(value)`
- Vérifier tous les fichiers avec `withOpacity` lors des refactorings
- Tester l'affichage après migration
- Documenter les changements dans les PRs
- Utiliser des constantes pour les valeurs d'alpha récurrentes

Valeurs d'alpha courantes:
- `alpha: 0.1` - Très léger (10%)
- `alpha: 0.2` - Léger (20%)
- `alpha: 0.3` - Subtile (30%)
- `alpha: 0.5` - Moyen (50%)
- `alpha: 0.7` - Prononcé (70%)
- `alpha: 0.9` - Fort (90%)
