---
description: INTERDIRE `double.infinity` en width dans `minimumSize` / `fixedSize` des ButtonStyle du thème Flutter
globs: apps/*/lib/core/theme/**/*.dart, apps/*/lib/**/*theme*.dart
alwaysApply: true
---

# Règle : `minimumSize` / `fixedSize` des button themes — jamais `double.infinity`

Contexte : DEC-012. `Size(double.infinity, H)` dans le thème global casse tous les boutons placés dans un Row / Dialog / contexte intrinsic layout avec l'erreur `BoxConstraints forces an infinite width` → widget invisible, ~2h de debug par occurence.

## ❌ Interdit

```dart
// Dans un ButtonStyle (elevatedButtonTheme, filledButtonTheme, outlinedButtonTheme)
ElevatedButton.styleFrom(
  minimumSize: const Size(double.infinity, 50), // ❌ KO
  fixedSize: const Size(double.infinity, 50),   // ❌ KO
)
```

## ✅ Obligatoire

```dart
ElevatedButton.styleFrom(
  // Contraint UNIQUEMENT la hauteur. Width libre → bouton peut se
  // placer dans un Row, un Dialog, un contexte intrinsic sans crasher.
  minimumSize: const Size.fromHeight(50),
)
```

## Pour un bouton full-width au site d'appel

```dart
// ✅ Pattern idiomatique Flutter
SizedBox(
  width: double.infinity,
  child: FilledButton(
    onPressed: ...,
    child: Text('Action'),
  ),
)

// Ou via un Column + crossAxisAlignment.stretch (le parent contraint)
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [FilledButton(...)],
)
```

## Rationale

- `minimumSize.width = infinity` force le bouton à demander une largeur infinie pendant `_computeSize`. Dans un contexte où le parent demande des intrinsics bornés (Row, Dialog, Flex), ça throw.
- Les intrinsics Flutter peuvent être appelés à des moments non-évidents (mouse tracker, hit test, AnimatedPadding du Dialog…). Le bug peut rester silencieux longtemps puis émerger dans un nouveau contexte.
- Pattern Flutter idiomatique : le **site d'appel** décide si le bouton est full-width ou pas — pas le thème.
