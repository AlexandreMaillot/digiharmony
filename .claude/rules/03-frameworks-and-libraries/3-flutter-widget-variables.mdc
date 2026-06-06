---
description: APPLIQUER ces variables finales LORS de la création d'un widget Flutter
globs: apps/*/lib/**/*_view.dart, apps/*/lib/**/*_page.dart
alwaysApply: true
---

Variables finales obligatoires:
- Créer des variables finales au début de chaque méthode build()
- Simplifier l'utilisation et améliorer les performances
- Éviter les appels répétés à Theme.of(context)

Variables obligatoires:
```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final localisation = context.l10n;
  
  // ... reste du code
}
```

Ordre des variables:
1. `final theme = Theme.of(context);`
2. `final textTheme = theme.textTheme;`
3. `final localisation = context.l10n;`

Utilisation dans le widget:
```dart
// ✅ Correct
Text(
  localisation.monTitre,
  style: textTheme.headlineLarge,
)

// ❌ Incorrect
Text(
  context.l10n.monTitre,
  style: Theme.of(context).textTheme.headlineLarge,
)
```

Variables optionnelles selon le contexte:
```dart
// Pour les widgets avec MediaQuery
final mediaQuery = MediaQuery.of(context);
final screenSize = mediaQuery.size;
final orientation = mediaQuery.orientation;

// Pour les widgets avec Bloc
final bloc = context.read<MonBloc>();
final state = context.watch<MonBloc>().state;

// Pour les widgets avec navigation
final navigator = Navigator.of(context);
final route = ModalRoute.of(context);
```

Bonnes pratiques:
- Toujours déclarer les variables finales au début du build()
- Utiliser des noms courts et explicites
- Éviter les appels répétés à context
- Grouper les variables par type (theme, navigation, bloc, etc.)
- Documenter les variables complexes si nécessaire

Interdictions strictes - Ne jamais passer en paramètre:
- INTERDIRE de passer `localisation` (L10n) en paramètre aux widgets
- INTERDIRE de passer `theme` (ThemeData) en paramètre aux widgets
- INTERDIRE de passer `textTheme` (TextTheme) en paramètre aux widgets
- Chaque widget DOIT obtenir ces variables via context dans son propre build()

Exemples interdits:
```dart
// ❌ Incorrect - Ne jamais passer localisation en paramètre
class MonWidget extends StatelessWidget {
  const MonWidget({required this.localisation, super.key});
  final L10n localisation;
}

// ❌ Incorrect - Ne jamais passer theme en paramètre
_GreetingRow(localisation: localisation)
_MonWidget(theme: theme, textTheme: textTheme)
```

Exemples corrects:
```dart
// ✅ Correct - Chaque widget obtient ses propres variables
class MonWidget extends StatelessWidget {
  const MonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localisation = context.l10n;
    
    return Text(localisation.monTexte, style: textTheme.bodyLarge);
  }
}

// ✅ Correct - Utilisation sans paramètres contextuels
const _GreetingRow()
MonWidget(donnees: mesDonnees)
```

Avantages:
- Code plus lisible et plus court
- Performance améliorée (moins d'appels à context)
- Consistance dans tout le codebase
- Maintenance facilitée
- Moins d'erreurs de typage
- Widgets indépendants et réutilisables
- Pas de couplage inutile entre widgets parents et enfants
