---
description: Catch silencieux sur un lookup qui peut échouer (`} on Object {}` ou `catch (_) {}`) masque les bugs pendant des semaines. Toujours afficher un feedback UX explicite + log developer.
globs:
  - "apps/**/lib/**/*.dart"
alwaysApply: false
---

# Erreur lookup — pas de catch silencieux

## Pourquoi

Cas vécu PR #808 : le chip « Clients favoris » de la page Nouvelle course
ne marchait **pas du tout** — clic = rien ne se passe. La cause : un catch
silencieux sur l'erreur de lookup `depotClients.obtenir(idClient)` :

```dart
Future<void> _onFavoriClique(...) async {
  try {
    final client = await depotClients.obtenir(idClient);
    if (client != null) bloc.add(NouvelleCourseClientSelectionne(client));
  } on Object {
    // Erreur lookup : silencieux côté UX, le user peut réessayer.
  }
}
```

Le bug avait **plusieurs semaines** : l'ID passé était incorrect (auth.uid
au lieu de `clients/{}.id`) → `obtenir(...)` retournait `null` → la
branche `if (client != null)` ne s'exécutait pas → rien ne se passait.
Aucun log, aucun feedback UX. Le user a juste constaté un widget mort.

## Règle

Pour tout lookup async (Firestore, HTTP, etc.) sur le critical path UX :

1. **Si lookup retourne `null` mais sans erreur** : afficher un feedback
   UX explicite (SnackBar, banner, état vide visible). Ne **jamais** rester
   silencieux sur un retour `null` qui devait être non-null selon l'intent.
2. **Si lookup lève une exception** : afficher un message UX adapté
   (« Erreur réseau, réessayez ») + **logger via `dart:developer`** avec
   le contexte (méthode, ID, message d'erreur).
3. Le catch silencieux est acceptable **uniquement** pour les opérations
   secondaires non-critiques (ex. pre-fetch optionnel, animation
   décorative).

## Exemple — bon réflexe

```dart
Future<void> _onFavoriClique(...) async {
  try {
    final client = await depotClients.obtenir(idClient);
    if (client == null) {
      // Pas une exception mais résultat inattendu → feedback explicite.
      developer.log(
        'favori clique: client introuvable id=$idClient',
        name: 'nouvelle_course',
      );
      _afficherSnack('Client introuvable. Saisis manuellement.');
      return;
    }
    bloc.add(NouvelleCourseClientSelectionne(client));
  } on Object catch (e, stack) {
    developer.log(
      'favori clique: erreur lookup',
      error: e, stackTrace: stack, name: 'nouvelle_course',
    );
    _afficherSnack('Erreur réseau. Réessaie dans un instant.');
  }
}
```

## Bypass acceptables

- Pré-chargement optionnel (cache warming) — catch silencieux OK car
  l'UX principale n'en dépend pas.
- Animation/décoration optionnelle.

## Anti-patterns à éviter

- ❌ `} on Object { /* silencieux */ }` sur un lookup critical UX.
- ❌ `if (result == null) { return; }` sans log ni feedback.
- ❌ `} catch (_) {}` qui mange même les erreurs de programmation.

## Référence

- PR #808 (`fix(admin): chip favori clients_stats`) — bug latent
  plusieurs semaines à cause d'un catch silencieux.
