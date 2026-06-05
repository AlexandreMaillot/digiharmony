---
name: claude
description: AI agent configuration and guidelines
---

# CLAUDE.md

> IMPORTANT: On first conversation message:
>
> - say "AI-Driven Development ON - Date: {current_date}, TZ: {current_timezone}." to User.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

DIGIHARMONY — app Flutter bien-être / santé mentale (public mineur, Erasmus+).
**Sans backend, sans Firebase, zéro collecte.** Monorepo Melos 7 (pub workspaces).

## Behavior Guidelines

All instructions and information above are willing to be up to date, but always remind yourself that USER can be wrong, be critical of the information provided, and verify it against the project's actual state.

- Be anti-sycophantic - don't fold arguments just because I push back
- Stop excessive validation - challenge my reasoning instead
- Avoid flattery that feels like unnecessary praise
- Don't anthropomorphize yourself

## Technical guidelines

- Do not commit or push yourself unless I ask you to.

### Answering Guidelines

- Don't assume your knowledge is up to date.
- Be 100% sure of your answers.
- If unsure, say "I don't know" or ask for clarification.
- Never say "you are right!", prefer anticipating mistakes.

## Commands

Monorepo Melos 7 (pub workspaces). Aucun script melos custom : commandes `flutter`/`dart`
lancées **depuis `apps/digiharmony_app/`** (sauf bootstrap, à la racine).

| But | Commande |
| --- | --- |
| Résoudre le workspace | `melos bootstrap` (ou `dart pub get` à la racine) |
| Lancer un flavor | `flutter run --flavor development --target lib/main_development.dart` (idem `staging`/`production`) |
| Codegen (Drift, json_serializable) | `dart run build_runner build --delete-conflicting-outputs` |
| i18n (8 langues ARB) | `flutter gen-l10n` |
| Lint / analyse | `flutter analyze` |
| Tous les tests | `flutter test` |
| Un fichier de test | `flutter test test/counter/view/counter_page_test.dart` |
| Un test par nom | `flutter test --name "renders CounterView"` |
| Build APK release | `./deploy.sh production` (= `flutter build apk --flavor production --target lib/main_production.dart --release`) |

> Lancer le codegen Drift **avant** les tests si les modèles de base ont changé. Lints :
> `very_good_analysis` + `bloc_lint`. Configs de lancement VS Code dans `.vscode/launch.json`.

## Architecture

Détails complets dans le memory bank (`aidd_docs/memory/`, chargé ci-dessous) ; ne sont
résumées ici que les contraintes structurantes qui nécessitent de croiser plusieurs fichiers.

- **Client-only, zéro collecte.** App Flutter monolithique, 100 % locale, **sans backend ni Firebase**. RGPD par absence de traitement. N'ajoute jamais de SDK réseau/analytics/tracking/Crashlytics ni de permission au-delà de `PACKAGE_USAGE_STATS`. Vibration via `HapticFeedback` (pas de permission `VIBRATE`).
- **Deux couches de persistance locales distinctes — ne pas mélanger.** `Drift` (SQLite) = journal d'humeur, conseils, agrégats (relationnel, réactif via `watch()`). `HydratedBloc` = état léger persistant (langue via `LocaleCubit`, flags onboarding/tuto). **Le journal ne va JAMAIS dans HydratedBloc** ; le compteur « 7 émotions négatives consécutives » est **dérivé** de Drift, jamais dupliqué. Voir `DEC-001`/`DEC-002`.
- **Monorepo Melos 7 = pub workspaces.** `resolution: workspace` dans chaque membre, un seul `pubspec.lock` racine. Ne fige pas `test ^x` dans un package membre (conflit avec le `test_api` épinglé par `flutter_test` → utiliser `test: any`).
- **3 flavors** (`development`/`staging`/`production`) avec entrypoints `lib/main_<flavor>.dart` ; **aucun** ne pointe vers une API.
- **i18n** gen-l10n / ARB, 8 langues (`en/fr/el/it/ro/tr/es/mk`, repli `en`), bascule live via `LocaleCubit` au-dessus de `MaterialApp`.
- **Android release : `minify`/`shrinkResources` doivent rester `false`** (sinon R8 strippe les libs natives Drift/sqlite3). Keystore + `key.properties` sont gitignorés — ne jamais committer.

## Memory Management

Project docs, memory, specs, and plans live in `aidd_docs/`.

### Project memory

<aidd_project_memory>
@aidd_docs/memory/architecture.md
@aidd_docs/memory/codebase-map.md
@aidd_docs/memory/coding-assertions.md
@aidd_docs/memory/deployment.md
@aidd_docs/memory/design-system.md
@aidd_docs/memory/project-brief.md
@aidd_docs/memory/project-overview.md
@aidd_docs/memory/testing.md
@aidd_docs/memory/vcs.md
</aidd_project_memory>

- If memory is not loaded above: run `ls -1tr aidd_docs/memory/` then read each file
- If needed: load files from `aidd_docs/memory/external/*` when user request it
- If needed: load files from `aidd_docs/memory/internal/*`, you have to think about it
