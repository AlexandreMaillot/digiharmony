---
description: UTILISER les extensions MediaQuery sur BuildContext LORS de la détection responsive
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

Principe:
- Créer des extensions sur BuildContext pour la détection responsive
- Éviter la duplication de logique MediaQuery dans chaque widget
- Centraliser la logique de détection de plateforme

Extension obligatoire à créer:
```dart
extension MediaQueryX on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width <= 600;
  bool get isTablet => MediaQuery.of(this).size.width > 600 && MediaQuery.of(this).size.width <= 1200;
  bool get isDesktop => MediaQuery.of(this).size.width > 1200;
}
```

Utilisation dans les widgets:
```dart
@override
Widget build(BuildContext context) {
  if (context.isDesktop) {
    return const MonWidgetDesktop();
  } else if (context.isTablet) {
    return const MonWidgetTablette();
  } else {
    return const MonWidgetMobile();
  }
}
```

Exemples corrects:
```dart
// ✅ Correct - Utilisation des extensions
class MaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return ActualitesViewBureau();
    } else if (context.isTablet) {
      return ActualitesViewTablette();
    } else {
      return ActualitesViewMobile();
    }
  }
}

// ✅ Correct - Dans un widget conditionnel
Widget buildContent(BuildContext context) {
  return context.isMobile 
    ? MobileContent()
    : DesktopContent();
}
```

Exemples interdits:
```dart
// ❌ Incorrect - Logique MediaQuery dupliquée
class MaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width > 1200;
    final isTablet = mediaQuery.size.width > 600 && mediaQuery.size.width <= 1200;
    
    if (isDesktop) {
      return ActualitesViewBureau();
    } else if (isTablet) {
      return ActualitesViewTablette();
    } else {
      return ActualitesViewMobile();
    }
  }
}

// ❌ Incorrect - Variables locales dans chaque widget
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth <= 600;
  // ... logique dupliquée
}
```

Seuils recommandés:
- Mobile: width <= 600px
- Tablette: 600px < width <= 1200px  
- Desktop: width > 1200px

Bonnes pratiques:
- Créer l'extension dans un fichier dédié (ex: lib/extensions/media_query_extension.dart)
- Exporter l'extension dans le barrel file principal
- Utiliser des seuils cohérents dans toute l'application
- Documenter les seuils choisis
- Tester sur différentes tailles d'écran

Avantages:
- Code plus lisible et expressif
- Élimination de la duplication de logique
- Maintenance centralisée des seuils
- Réutilisabilité dans tous les widgets
- Cohérence dans toute l'application

Migration:
```dart
// ❌ Avant
final mediaQuery = MediaQuery.of(context);
final isDesktop = mediaQuery.size.width > 1200;

// ✅ Après  
if (context.isDesktop) {
  // ...
}
```
