---
name: coding-assertions
description: Code quality verification checklist
argument-hint: N/A
scope: all
---

# Coding Guidelines

> Those rules must be minimal because the MUST be checked after EVERY CODE GENERATION.

## Requirements to complete a feature

**A feature is really completed if ALL of the above are satisfied: if not, iterate to fix all until all are green.**

- Lints `very_good_analysis` + `bloc_lint` passent (0 warning/info, mode strict).
- State via `bloc`/`flutter_bloc` ; persistance légère (langue/flags) via `HydratedBloc`.
- Journal d'humeur JAMAIS dans `HydratedBloc` — toujours dérivé de `Drift`.
- Persistance locale = `Drift` uniquement (aucune autre solution).
- Après modif modèle Drift : `dart run build_runner build --delete-conflicting-outputs`.
- Toute chaîne UI passe par l'ARB (gen-l10n) — 8 langues ; el/ro/tr/mk = relecture locuteur natif.
- Zéro collecte : aucun SDK réseau/analytics/tracking/Crashlytics ; pas de notif/push (bandeau in-app).
- Permissions : seule `PACKAGE_USAGE_STATS` (Android) autorisée ; vibration via `HapticFeedback` (pas de `VIBRATE`).
- Android release : `isMinifyEnabled = false` et `isShrinkResources = false` (protège libs natives Drift).

## Commands to run

- `Before commit`: minimal check to build a feature
- `Before push`: heavier check ran before push

### Before commit

```markdown
| Order | Command | Description |
| ----- | ------- | ----------- |
| 1 | `dart run build_runner build --delete-conflicting-outputs` | Regen Drift/codegen (si modèles modifiés) |
| 2 | `melos exec -- dart format --set-exit-if-changed .` | Format strict |
| 3 | `melos exec -- dart analyze --fatal-infos` | Lints `very_good_analysis` + `bloc_lint` |
| 4 | `melos exec --dir-exists=test -- flutter test` | Tests unitaires/bloc |
```

### Before push

```markdown
| Order | Command | Description |
| ----- | ------- | ----------- |
| 1 | `flutter gen-l10n` | Vérifie ARB / 8 langues à jour |
| 2 | `flutter build apk --release` | Build release Android (minify/shrink off) |
| 3 | `flutter build ios --release --no-codesign` | Build release iOS |
```
