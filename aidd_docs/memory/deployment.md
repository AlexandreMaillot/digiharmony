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

## Identité d'app (icône, splash, nom) — production-only via flavor

- **Génération** (dev-dependencies, build-time, aucun runtime/collecte) :
  - Icône : `dart run flutter_launcher_icons -f flutter_launcher_icons-production.yaml`
    → écrit dans `android/app/src/production/res/` (icône **adaptative** : foreground plein cadre,
    `adaptive_icon_background = #16213C`, inset retiré pour remplir le cercle). Source :
    `tool/icon/app_icon_1024.png`. **iOS non régénéré par l'outil** : `AppIcon.appiconset` régénéré à part
    depuis la source **sans canal alpha** (rejet App Store sinon).
  - Splash : `dart run flutter_native_splash:create --flavor production` (config
    `flutter_native_splash-production.yaml`, `#16213C` + logo carré) → `android/app/src/production/` +
    iOS `LaunchScreenProduction.storyboard` + imagesets.
- **Production-only réellement isolé** : seul `src/production` (Android) et les 3 configs Xcode
  `*-production` portent la nouvelle identité ; `development`/`staging` gardent leurs icônes + `LaunchScreen`.
  - iOS : `Info.plist` → `UILaunchStoryboardName = $(LAUNCH_STORYBOARD_NAME:default=LaunchScreen)` ; seules
    les configs production définissent `LAUNCH_STORYBOARD_NAME = LaunchScreenProduction` (cf. rule
    `3-flutter-ios-infoplist-key-build-variable`). Le storyboard doit être **ajouté au projet Xcode**
    (PBXFileReference + BuildFile + Resources), sinon introuvable au runtime.
- **Nom d'app** (sans « App ») : `Digiharmony` / `[STG] Digiharmony` / `[DEV] Digiharmony` — Android
  `manifestPlaceholders["appName"]` (`build.gradle.kts`) + iOS `FLAVOR_APP_NAME` (→ `CFBundleDisplayName`).
- Détail : DEC-007 (`internal/decisions/0007-identite-app-flavor.md`).

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

- Bundle IDs par flavor : `com.creappi.digiharmony` (prod) / `.stg` / `.dev` ; configs Xcode
  `Debug/Release/Profile-{production,staging,development}`, AppIcon `AppIcon`/`AppIcon-stg`/`AppIcon-dev`.
- Configuré : Screen Time (DEC-006, capability Family Controls Development), icône/splash/nom production
  (voir « Identité d'app »). **Distribution App Store** : nécessite l'entitlement
  `com.apple.developer.family-controls` approuvé par Apple + provisioning (hors code).

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
