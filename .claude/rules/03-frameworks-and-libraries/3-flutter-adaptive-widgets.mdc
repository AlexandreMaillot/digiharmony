---
description: APPLIQUER les widgets adaptatifs LORS de l'utilisation de widgets natifs Flutter
globs: apps/*/lib/**/*_view.dart, apps/*/lib/**/*_page.dart
alwaysApply: true
---

Principe:
- Utiliser la version .adaptive() dès qu'elle existe pour un widget
- Assurer la cohérence visuelle iOS/Android automatiquement
- Préférer l'adaptabilité native aux widgets custom
- Améliorer l'expérience utilisateur sur toutes les plateformes

Widgets avec version adaptative disponible:

Indicateurs de progression:
- CircularProgressIndicator.adaptive()
- LinearProgressIndicator.adaptive()

Contrôles interactifs:
- Switch.adaptive()
- Slider.adaptive()
- Checkbox.adaptive()
- Radio.adaptive()

Navigation:
- BackButton.adaptive()
- CloseButton.adaptive()

Sélecteurs:
- DatePicker.adaptive()
- TimePicker.adaptive()

Règles d'utilisation:
- Toujours préférer .adaptive() à la version standard
- Ne pas créer de widgets custom si une version adaptative existe
- Tester sur iOS et Android pour valider l'adaptabilité
- Documenter les cas où l'adaptabilité n'est pas souhaitée

Exemples corrects:
```dart
// Indicateurs de progression
const CircularProgressIndicator.adaptive()
const LinearProgressIndicator.adaptive(value: 0.5)

// Contrôles interactifs
Switch.adaptive(
  value: isEnabled,
  onChanged: (value) => setState(() => isEnabled = value),
)
Slider.adaptive(
  value: currentValue,
  onChanged: (value) => setState(() => currentValue = value),
)
Checkbox.adaptive(
  value: isChecked,
  onChanged: (value) => setState(() => isChecked = value),
)

// Navigation
const BackButton.adaptive()
const CloseButton.adaptive()
```

Exemples interdits:
```dart
// ❌ Versions non adaptatives
const CircularProgressIndicator()
Switch(value: true, onChanged: null)
Slider(value: 0.5, onChanged: null)
const BackButton()
```

Cas spéciaux:
- Utiliser la version standard uniquement si le design nécessite une apparence spécifique
- Documenter pourquoi l'adaptabilité n'est pas utilisée
- Préférer les paramètres de thème pour personnaliser l'apparence

Avantages:
- Cohérence visuelle automatique iOS/Android
- Moins de code de maintenance
- Meilleure expérience utilisateur native
- Respect des guidelines de chaque plateforme