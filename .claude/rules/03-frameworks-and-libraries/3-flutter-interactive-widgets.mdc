---
description: INTERDIRE l'enveloppement de widgets interactifs natifs avec InkWell ou GestureDetector
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

Principe:
- Les widgets interactifs natifs Flutter ont déjà leur propre gestion des interactions
- Envelopper ces widgets avec InkWell ou GestureDetector crée des conflits et des bugs visuels
- Un widget avec onSelected/onTap/onPressed null est considéré comme désactivé et applique une opacité réduite

Règle absolue:
- INTERDIRE InkWell ou GestureDetector autour d'un widget qui a déjà onSelected, onTap, onPressed, onChanged, etc.
- TOUJOURS utiliser directement le callback du widget natif
- JAMAIS mettre onSelected/onTap/onPressed à null pour contourner un problème

Widgets concernés:
- ChoiceChip, FilterChip, ActionChip (onSelected)
- ElevatedButton, OutlinedButton, TextButton (onPressed)
- Switch, Checkbox, Radio (onChanged)
- InkWell, GestureDetector (onTap)
- ListTile (onTap)
- Card (onTap si présent)
- Tous les widgets avec callbacks d'interaction natifs

Exemples interdits:
```dart
// ❌ InkWell autour d'un ChoiceChip
InkWell(
  onTap: () => bloc.add(Event()),
  child: ChoiceChip(
    onSelected: null, // Widget désactivé = texte atténué
    ...
  ),
)

// ❌ GestureDetector autour d'un Button
GestureDetector(
  onTap: () => action(),
  child: ElevatedButton(
    onPressed: null, // Button désactivé
    ...
  ),
)

// ❌ InkWell autour d'un Switch
InkWell(
  onTap: () => toggle(),
  child: Switch(
    onChanged: null, // Switch désactivé
    ...
  ),
)
```

Exemples corrects:
```dart
// ✅ Utiliser directement onSelected
ChoiceChip(
  onSelected: (_) => bloc.add(Event()),
  ...
)

// ✅ Utiliser directement onPressed
ElevatedButton(
  onPressed: () => action(),
  ...
)

// ✅ Utiliser directement onChanged
Switch(
  onChanged: (value) => toggle(value),
  ...
)

// ✅ InkWell sur un widget non interactif
InkWell(
  onTap: () => action(),
  child: Container(...), // Widget sans callback natif
)
```

Cas spéciaux:
- Si un widget n'a pas de callback natif (Container, Column, etc.), InkWell/GestureDetector est autorisé
- Si on veut désactiver un widget, utiliser un booléen dans le callback, pas null
- Exemple: `onPressed: isEnabled ? () => action() : null` est correct

Conséquences du non-respect:
- Widget considéré comme désactivé (opacité réduite)
- Texte atténué/pâle
- Interactions bloquées ou conflictuelles
- Bugs visuels difficiles à diagnostiquer
