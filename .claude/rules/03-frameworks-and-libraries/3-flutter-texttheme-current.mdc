---
description: APPLIQUER les propriétés textTheme actuelles LORS de l'utilisation du thème Flutter
globs: apps/*/lib/**/*_view.dart, apps/*/lib/**/*_page.dart
alwaysApply: true
---

Propriétés textTheme actuelles (Flutter 3.x):
- Utiliser les propriétés actuelles, pas les dépréciées
- Vérifier la documentation officielle avant d'utiliser une propriété
- Éviter les propriétés obsolètes pour éviter les warnings

Propriétés actuelles par catégorie:

Display (plus grandes):
- theme.textTheme.displayLarge
- theme.textTheme.displayMedium  
- theme.textTheme.displaySmall

Headline (titres principaux):
- theme.textTheme.headlineLarge
- theme.textTheme.headlineMedium
- theme.textTheme.headlineSmall

Title (titres de sections):
- theme.textTheme.titleLarge
- theme.textTheme.titleMedium
- theme.textTheme.titleSmall

Body (texte principal):
- theme.textTheme.bodyLarge
- theme.textTheme.bodyMedium
- theme.textTheme.bodySmall

Label (labels et boutons):
- theme.textTheme.labelLarge
- theme.textTheme.labelMedium
- theme.textTheme.labelSmall

Convention responsive par plateforme:
- **Small** (bodySmall, titleSmall, labelSmall, headlineSmall, displaySmall) → **Mobile**
- **Medium** (bodyMedium, titleMedium, labelMedium, headlineMedium, displayMedium) → **Tablette**
- **Large** (bodyLarge, titleLarge, labelLarge, headlineLarge, displayLarge) → **Bureau/Desktop**

Règles strictes de la convention responsive:
- OBLIGATOIRE : Adapter la taille du texte selon la plateforme cible de la vue
- INTERDIRE : Utiliser *Large dans une vue mobile (_view_mobile.dart)
- INTERDIRE : Utiliser *Small dans une vue bureau (_view_bureau.dart)
- RECOMMANDÉ : Utiliser *Medium dans les vues tablette (_view_tablette.dart)

Exemples par plateforme:
```dart
// ✅ Dans une vue mobile (_view_mobile.dart)
Text(localisation.monTexte, style: textTheme.bodySmall)
Text(localisation.monTitre, style: textTheme.titleSmall)
Text(localisation.monLabel, style: textTheme.labelSmall)

// ✅ Dans une vue tablette (_view_tablette.dart)
Text(localisation.monTexte, style: textTheme.bodyMedium)
Text(localisation.monTitre, style: textTheme.titleMedium)
Text(localisation.monLabel, style: textTheme.labelMedium)

// ✅ Dans une vue bureau (_view_bureau.dart)
Text(localisation.monTexte, style: textTheme.bodyLarge)
Text(localisation.monTitre, style: textTheme.titleLarge)
Text(localisation.monLabel, style: textTheme.labelLarge)
```

Exemples interdits:
```dart
// ❌ bodyLarge dans une vue mobile
// Fichier: ma_page_view_mobile.dart
Text(localisation.monTexte, style: textTheme.bodyLarge) // INTERDIT

// ❌ titleSmall dans une vue bureau
// Fichier: ma_page_view_bureau.dart
Text(localisation.monTitre, style: textTheme.titleSmall) // INTERDIT
```

Variables finales obligatoires:
```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final localisation = context.l10n;
  
  // ... reste du code
}
```

Exemples corrects:
```dart
// Titres principaux
Text(
  localisation.monTitre,
  style: textTheme.headlineLarge,
)

// Titres de sections
Text(
  localisation.monSousTitre,
  style: textTheme.titleLarge,
)

// Texte principal
Text(
  localisation.monTexte,
  style: textTheme.bodyLarge,
)

// Labels et boutons
Text(
  localisation.monLabel,
  style: textTheme.labelLarge,
)
```

Propriétés dépréciées à éviter:
- headline1, headline2, headline3, headline4, headline5, headline6
- bodyText1, bodyText2
- caption, button, subtitle1, subtitle2
- overline

Bonnes pratiques:
- Créer des variables finales au début du build() pour theme, textTheme et localisation
- Ne jamais utiliser Theme.of(context) directement dans les widgets
- Vérifier la documentation Flutter avant d'utiliser une propriété
- Utiliser des constantes pour les styles récurrents
- Tester l'apparence sur différentes tailles d'écran
- Respecter la hiérarchie typographique (display > headline > title > body > label)

Migration des anciennes propriétés:
```dart
// ❌ Déprécié
theme.textTheme.headline1 → theme.textTheme.displayLarge
theme.textTheme.headline2 → theme.textTheme.displayMedium
theme.textTheme.headline3 → theme.textTheme.displaySmall
theme.textTheme.headline4 → theme.textTheme.headlineLarge
theme.textTheme.headline5 → theme.textTheme.headlineMedium
theme.textTheme.headline6 → theme.textTheme.headlineSmall
theme.textTheme.bodyText1 → theme.textTheme.bodyLarge
theme.textTheme.bodyText2 → theme.textTheme.bodyMedium
theme.textTheme.button → theme.textTheme.labelLarge
theme.textTheme.caption → theme.textTheme.bodySmall
theme.textTheme.overline → theme.textTheme.labelSmall
```
