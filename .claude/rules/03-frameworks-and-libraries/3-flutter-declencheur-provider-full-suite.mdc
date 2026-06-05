---
description: Quand une route/page (ou app.dart) lit un NOUVEAU provider via context.read pour construire un bloc (ex. déclencheur de notif best-effort), tous les tests de vue/navigation qui montent cette page sans le provider cassent. Lecture défensive + TOUJOURS relancer le FULL suite de l'app (pas seulement les tests ciblés).
globs:
  - "apps/**/lib/**/views/**/*.dart"
  - "apps/**/lib/**/pages/**/*.dart"
  - "apps/**/lib/app/**/*.dart"
alwaysApply: false
---

# Flutter — déclencheur via nouveau provider : lecture défensive + full suite

## Pourquoi

Pattern récurrent (notifications #924, PR-1b/1c/2b/2c/3b/4b) : on injecte un
nouveau dépôt (ex. `DepotNotificationsCourse`) et la **route/page** le lit via
`context.read<T>()` pour construire son bloc. Conséquence : **tout test de vue
ou de navigation** qui monte cette page sans fournir `T` lève
`ProviderNotFoundException` — et ces tests sont souvent dans d'autres fichiers
(navigation, app_test, bannières) que ceux qu'un agent valide en « tests
ciblés ». Vécu **4 fois** : les tests ciblés passent, le **full suite** casse.

Variante backend vécue : un dépôt HTTP qui lit `FirebaseAuth.instance` **dans
son constructeur** fait crasher l'app entière au build en test (Firebase non
initialisé) → `app_test` rouge.

## Règle

1. **Lecture défensive** quand le provider alimente un effet **best-effort**
   (notif, analytics…) : la page doit pouvoir s'ouvrir sans lui.
   ```dart
   T? _lireOuNull(BuildContext context) {
     try { return context.read<T>(); }
     on ProviderNotFoundException { return null; }
   }
   ```
   Et le bloc accepte le dépôt en paramètre **nullable** (no-op si null).

2. **Constructeur sans I/O** : un dépôt HTTP résout `FirebaseAuth.instance`
   **paresseusement** (getter), jamais au constructeur.

3. **Toujours relancer le FULL suite de l'app** après avoir branché un
   déclencheur sur un nouveau provider (`flutter test` complet), pas seulement
   les tests des fichiers touchés — c'est là que les régressions de vue
   apparaissent. (Les agents ne lancent que les tests ciblés : re-valider.)
