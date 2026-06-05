---
description: PROTÉGER le handler `FlutterError.onError` du cast `StackTrace?` qui throw en Flutter web dev-mode (DDC)
globs: apps/*/lib/bootstrap.dart, apps/*/lib/main*.dart
alwaysApply: true
---

# Règle : `FlutterError.onError` défensif en Flutter web

## Contexte

En Flutter **web mode développement (DDC)**, `FlutterErrorDetails.stack` est typé `StackTrace?` côté API, mais l'implémentation peut y stocker un `LegacyJavaScriptObject` (objet JS brut) au lieu d'un vrai `StackTrace` Dart. Quand on le passe directement à `log(stackTrace: ...)` ou tout autre paramètre typé, le cast implicite throw :

```
TypeError: Instance of 'LegacyJavaScriptObject': type 'LegacyJavaScriptObject' is not a subtype of type 'StackTrace?'
```

Ce `TypeError` est lui-même une erreur Flutter, qui **redéclenche** `FlutterError.onError`, qui re-throw le même TypeError → **boucle infinie de logs** qui noie la console et masque les vraies exceptions upstream.

En production (AOT compilé) le bug n'existe pas, mais le dev-mode web DDC est bloqué si on ne se protège pas.

## ❌ Interdit

```dart
FlutterError.onError = (details) {
  log(details.exceptionAsString(), stackTrace: details.stack); // ❌ KO web dev
};
```

## ✅ Obligatoire

```dart
FlutterError.onError = (details) {
  final stack = details.stack;
  log(
    details.exceptionAsString(),
    // En Flutter web dev (DDC), `stack` peut être un LegacyJavaScriptObject
    // au lieu d'un vrai StackTrace → on filtre explicitement.
    stackTrace: stack is StackTrace ? stack : null,
  );
};
```

Même pattern pour `PlatformDispatcher.instance.onError` et tout autre handler qui consomme une `StackTrace?` depuis Flutter framework :

```dart
PlatformDispatcher.instance.onError = (error, stack) {
  log(
    'Erreur non capturée',
    error: error,
    stackTrace: stack is StackTrace ? stack : null,
  );
  return true;
};
```

## Détection d'une occurence du bug

Si la console Chrome spam :

```
[log] Error: TypeError: Instance of 'LegacyJavaScriptObject': type 'LegacyJavaScriptObject' is not a subtype of type 'StackTrace?'
  ... bootstrap.dart:XXX  (ou main.dart)
```

→ c'est cette règle qui n'a pas été appliquée. La **vraie exception** upstream est masquée — appliquer le fix révèle le message réel.
