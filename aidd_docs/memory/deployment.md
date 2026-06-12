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
    (iOS = TestFlight, pas App Distribution — voir « iOS »).
  - Groupes testeurs : `testeurs`, `dev`, `client`. Diffuser `.stg`/`.dev` exige une app Firebase
    dédiée par package + `FIREBASE_ANDROID_APP_ID` surchargé.

## Pages légales

- **Firebase Hosting** (`dev-digiharmony`) : `https://dev-digiharmony.web.app/{privacy_policy,
  terms_of_service,legal_notice}.html`. Sources dans `legal_pages/`, config `firebase.json` +
  `.firebaserc` à la racine, URLs câblées dans `lib/config/legal_urls.dart`. Déploiement :
  `firebase deploy --only hosting`. Politique « zéro donnée ».
- Exigée par Play Console même sans collecte.

## iOS

- Bundle IDs par flavor : `com.creappi.digiharmony` (prod) / `.stg` / `.dev` ; configs Xcode
  `Debug/Release/Profile-{production,staging,development}`, AppIcon `AppIcon`/`AppIcon-stg`/`AppIcon-dev`.
- Configuré : Screen Time (DEC-006, capability Family Controls), icône/splash/nom production
  (voir « Identité d'app »). Entitlement `com.apple.developer.family-controls` **distribution
  approuvé par Apple** → diffusion TestFlight **opérationnelle** (DEC-006, vérifié 2026-06-12).

### TestFlight (iOS) — procédure CLI

`deploy.sh` ne build que l'APK Android ; iOS = TestFlight, fait à la main / via la clé ASC.

1. **Clé App Store Connect API** (Team Key) : issuer `26aaca42-0bb5-445c-a421-681c049086de`,
   team `XU6QP9KZYD`, `.p8` **HORS VCS** dans `~/.private_keys/` (jamais committée ; les vieilles
   clés révoquées ne figurent plus dans *Users & Access → Integrations → Team Keys*).
2. **Archive** : `flutter build ios --config-only --release --flavor production --target lib/main_production.dart`
   puis archive Xcode (scheme `production`, config `Release-production`).
3. **Signing distribution** (absent localement par défaut, seuls des certs *Development*) : créer le
   cert **Apple Distribution** + profils **App Store** pour `com.creappi.digiharmony` **ET**
   `…DeviceActivityReportExtension` (family-controls) via la clé API
   (`-allowProvisioningUpdates -authenticationKey*`).
4. **Export IPA** : `xcodebuild -exportArchive … -exportOptionsPlist` (method `app-store`,
   `signingStyle automatic`). ⚠️ Un **prompt keychain `codesign`** apparaît sur l'écran de la machine
   → cliquer **« Toujours autoriser »** sinon l'export reste bloqué (session non-interactive = hang).
5. **Upload** : `xcrun altool --upload-app --type ios -f Digiharmony.ipa --apiKey <KeyID> --apiIssuer <issuer>`.
6. **Conformité export** : `usesNonExemptEncryption=false` (app locale, pas de crypto non-standard).
7. **Groupes `dev`/`client` = INTERNES** : pas d'assignation build-par-build (l'API la refuse) ;
   les testeurs internes accèdent **automatiquement** à tout build passé en `VALID` / `IN_BETA_TESTING`.

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
