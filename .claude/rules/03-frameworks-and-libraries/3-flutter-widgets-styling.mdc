---
description: APPLIQUER ces contraintes de style LORS de la création de widgets Flutter
globs: apps/*/lib/**/*_view.dart, apps/*/lib/**/*_page.dart
alwaysApply: true
---

Widgets natifs:
- Utiliser AU MAXIMUM les widgets natifs de Flutter
- Privilégier les widgets Material ou Cupertino
- Éviter les widgets custom quand une alternative native existe
- Composer les widgets natifs pour créer des patterns

Widgets adaptatifs:
- Utiliser la version .adaptive() dès qu'elle existe
- Exemples: CircularProgressIndicator.adaptive(), Switch.adaptive(), Slider.adaptive()
- Assurer la cohérence visuelle iOS/Android automatiquement
- Préférer l'adaptabilité native aux widgets custom

Styling et thème:
- INTERDIRE les styles custom inline
- Utiliser exclusivement le thème de l'application
- Accéder au thème via `Theme.of(context)`
- Utiliser les propriétés du thème (colorScheme, textTheme, etc.)

Espacements obligatoires:
- Utiliser UNIQUEMENT des multiples de 5
- Valeurs autorisées: 5, 10, 15, 20, 25, 30, etc.
- INTERDIRE: 8, 12, 16, 24, 32, etc.
- Remplacer 16 par 15, 8 par 10, 24 par 25

Interdictions strictes:
- Pas de nombres magiques dans le code
- Pas de valeurs hardcodées non multiples de 5
- Pas de styles inline (color, fontSize, etc.)
- Pas de widgets custom pour du styling simple

Constantes d'espacement:
- Créer des constantes si réutilisation
- Nommer explicitement (ESPACEMENT_PETIT, ESPACEMENT_MOYEN)
- Utiliser des constantes de classe ou globales
- Documenter l'usage des constantes

Exemples corrects:
```dart
const SizedBox(height: 5)
const SizedBox(height: 10)
const SizedBox(height: 15)
const SizedBox(height: 20)
padding: EdgeInsets.all(15)
const CircularProgressIndicator.adaptive()
const Switch.adaptive(value: true, onChanged: null)
const Slider.adaptive(value: 0.5, onChanged: null)
```

Exemples interdits:
```dart
const SizedBox(height: 8)   // Utiliser 10
const SizedBox(height: 16)  // Utiliser 15
padding: EdgeInsets.all(24) // Utiliser 25
const CircularProgressIndicator()  // Utiliser .adaptive()
const Switch(value: true, onChanged: null)  // Utiliser .adaptive()
```
