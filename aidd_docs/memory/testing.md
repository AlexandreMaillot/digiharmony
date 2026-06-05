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
- Exemple very_good : `test/widget_test.dart`, `test/app/view/app_test.dart`, `test/counter/...` — 7 tests passent.
- Helper `PumpApp` (`test/helpers/pump_app.dart`) injecte les `localizationsDelegates`.

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
- Cubits/blocs : `blocTest` avec `build`/`act`/`expect`.
