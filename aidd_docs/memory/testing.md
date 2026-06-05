---
name: testing
description: Testing strategy and guidelines
argument-hint: N/A
scope: all
---

# Testing Guidelines

## Tools and Frameworks

- `flutter_test` — tests unitaires + widgets.
- `bloc_test` — tests cubits/blocs.
- `mocktail` — mocks/stubs.
- Lint : `very_good_analysis` + `bloc_lint`.

## Testing Strategy

État actuel (en place) :
- Phase 1 testée (Fondations + Demarrage + Accueil) : ~111 tests verts (unitaires, `bloc_test`, widgets, Drift en mémoire). Tests en miroir de `lib/pages/<page>/`.
- Helpers dans `test/helpers/` (init storage HydratedBloc pour les tests).

Convention cible (à construire) :
- Unitaires : logique métier `core_package`, cubits/blocs.
- Widgets : pages/composants via `pumpApp`.
- Couche Drift : DB en mémoire (`NativeDatabase.memory()`).
- Pas de backend → aucun test d'intégration API.
- E2E : non configuré (Maestro envisageable plus tard, hors périmètre).

## Test Execution Process

- Par app : `flutter test`.
- Monorepo : `melos exec -- flutter test` (aucun script melos custom défini).
- Si modèles Drift modifiés : `dart run build_runner build` avant les tests.

## Mocking and Stubbing

- `mocktail` : `class MockX extends Mock implements X {}`, `when(...)` / `verify(...)`.
- Blocs : `blocTest` avec `build`/`act`/`expect` (transformer explicite testé si concurrency).

## Pièges connus

- **`flutter_animate` en boucle infinie (`.repeat`) ⇒ `pumpAndSettle()` ne se stabilise jamais** (timeout). Les écrans Demarrage/Accueil (halo, particules) en contiennent. Dans les tests widgets touchant ces écrans : wrapper le `MaterialApp` avec `MediaQuery(disableAnimations: true)` **ou** piloter le temps avec des `pump(Duration)` finis ciblés — JAMAIS `pumpAndSettle()`.
- **`gen-l10n` avant `flutter test`** si des clés ARB ont changé (sinon `AppLocalizations` désynchronisé).
- **Drift créée plusieurs fois** : injecter une `AppDatabase` mockée/en mémoire par test pour éviter le warning « created multiple times » + des timers pendants.
