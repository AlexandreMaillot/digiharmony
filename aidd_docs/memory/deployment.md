---
name: deployment
description: Infrastructure and deployment documentation
argument-hint: N/A
scope: all
---

# Deployment

App Flutter uniquement. Pas d'API, pas de backend, **aucun SDK Firebase embarqué**, zéro
collecte. Firebase est utilisé **hors app** uniquement : projet `dev-digiharmony` pour le
**Hosting** (pages légales) et **App Distribution** (diffusion testeurs) — aucun `firebase_*`,
aucun `google-services.json`, aucune `firebase_options.dart` dans le code.

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
- **Firebase App Distribution** (projet `dev-digiharmony`, hors app, aucun SDK) : `deploy.sh`
  **diffuse par défaut** (`DISTRIBUTE=0` pour builder seul ; `GROUPS=<alias>` pour cibler).
  - App Android : `com.creappi.digiharmony` (flavor production), App ID
    `1:614105312744:android:897629d5752390e47e485d`.
  - App iOS : `com.creappi.digiharmony`, App ID `1:614105312744:ios:7eee4e69653e42087e485d`
    (non diffusable en l'état — voir « iOS »).
  - Groupes testeurs : `testeurs`, `dev`. Diffuser `.stg`/`.dev` exige une app Firebase dédiée
    par package + `FIREBASE_ANDROID_APP_ID` surchargé.

## Pages légales

- **Firebase Hosting** (`dev-digiharmony`) : `https://dev-digiharmony.web.app/{privacy_policy,
  terms_of_service,legal_notice}.html`. Sources dans `legal_pages/`, config `firebase.json` +
  `.firebaserc` à la racine, URLs câblées dans `lib/config/legal_urls.dart`. Déploiement :
  `firebase deploy --only hosting`. Politique « zéro donnée ».
- Exigée par Play Console même sans collecte.

## iOS

- Bundle IDs par flavor : `com.creappi.digiharmony` (prod) / `.stg` / `.dev` ; configs Xcode
  `Debug/Release/Profile-{production,staging,development}`, AppIcon `AppIcon`/`AppIcon-stg`/`AppIcon-dev`.
- Configuré : Screen Time (DEC-006, capability Family Controls Development), icône/splash/nom production
  (voir « Identité d'app »). **Distribution App Store** : nécessite l'entitlement
  `com.apple.developer.family-controls` approuvé par Apple + provisioning (hors code).
- **App Distribution iOS bloqué** : `Runner` ET l'extension `DeviceActivityReportExtension` déclarent
  `com.apple.developer.family-controls` ; tout IPA de distribution (app-store/ad-hoc) échoue tant que
  l'entitlement Family Controls **distribution** n'est pas approuvé par Apple
  (`developer.apple.com/contact/request/family-controls-distribution`). Contournement test :
  `flutter build ipa --export-method development` (UDID enregistrés) puis upload manuel. `deploy.sh`
  ne build que l'APK Android.

# Infrastructure

## Project Structure

```plaintext
apps/digiharmony_app/
├── deploy.sh                          # build APK release + App Distribution (DISTRIBUTE=0 pour build seul)
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
