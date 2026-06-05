---
name: deployment
description: Infrastructure and deployment documentation
argument-hint: N/A
scope: all
---

# Deployment

App Flutter uniquement. Pas d'API, pas de backend, pas de Firebase/Cloud Run, zéro collecte.

## Build & Release

- Script : `apps/digiharmony_app/deploy.sh [flavor]` (défaut `production`).
- Build : `flutter build apk --flavor <flavor> --target lib/main_<flavor>.dart --release`.
- Sortie : `build/app/outputs/flutter-apk/app-<flavor>-release.apk`.
- App Bundle Play : commenté dans le script (`flutter build appbundle ...`).
- Flavors : `development` / `staging` / `production`.
  - Suffixes `applicationId` : `.dev` / `.stg` / `(aucun)`.

## CI/CD Pipeline

- État actuel : aucun pipeline CI/CD configuré ; build & release **manuels** via `deploy.sh`.

## Signature Android

- Keystore : `apps/digiharmony_app/android/digiharmony_keystore.jks` (HORS VCS).
- Config dans `android/app/build.gradle.kts`, deux sources :
  - Env : `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_ALIAS`, `ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD`, `ANDROID_KEYSTORE_PASSWORD`.
  - Sinon `android/key.properties` (`keyAlias`, `keyPassword`, `storeFile`, `storePassword`).
- `key.properties` + `.jks` : HORS VCS, jamais publiés, secrets jamais en clair.

## Minify / shrinkResources

- Release : `isMinifyEnabled = false`, `isShrinkResources = false`.
- Raison : R8/proguard strippe sinon les libs natives Drift / sqlite3_flutter_libs (crash SQLite runtime).
- Détail : `aidd_docs/rules/android-gradle-minify-off.md`.

## Distribution

- APK direct ou piste interne Play Console.
- Firebase App Distribution : **optionnel**, hors app, aucun SDK Firebase embarqué (commande commentée dans `deploy.sh`).

## Pages légales

- GitHub Pages / `digiharmony.org`, politique « zéro donnée ».
- Exigée par Play Console même sans collecte.

## iOS

- Bundle ID : `com.creappi.digiharmony`.
- Prévu après Android (convention, non encore configuré).

# Infrastructure

## Project Structure

```plaintext
apps/digiharmony_app/
├── deploy.sh                          # build APK release par flavor
├── lib/main_<flavor>.dart             # entrypoints development/staging/production
└── android/
    ├── key.properties                 # HORS VCS — config signature
    ├── digiharmony_keystore.jks        # HORS VCS — keystore release
    └── app/build.gradle.kts           # signingConfigs, flavors, minify off
```

## Environment Variables

### Signature release (optionnelles, sinon `key.properties`)

- `ANDROID_KEYSTORE_PATH`
- `ANDROID_KEYSTORE_ALIAS`
- `ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD`
- `ANDROID_KEYSTORE_PASSWORD`
