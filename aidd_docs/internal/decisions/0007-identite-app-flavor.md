# Decision: Identité d'app (icône, splash, nom) production-only via overrides par flavor

| Field   | Value                       |
| ------- | --------------------------- |
| ID      | DEC-007                     |
| Date    | 2026-06-06                  |
| Feature | Identité d'app (icône/splash/nom) |
| Status  | Accepted                    |

## Context

L'app a 3 flavors (`development`/`staging`/`production`) déjà différenciés (suffixes bundle id,
icônes adaptatives dev/staging, noms). Il fallait poser une **nouvelle identité visuelle** (icône, splash
avec logo, nom sans « App ») **uniquement sur production**, sans toucher dev/staging (qui restent
distinguables en test), et sans collecte ni nouvelle permission.

## Decision

Appliquer la nouvelle identité **production-only via les overrides de ressources par flavor** :

- **Icône** : `flutter_launcher_icons` en mode flavor (`flutter_launcher_icons-production.yaml`,
  `dart run flutter_launcher_icons -f …`) → sortie dans `android/app/src/production/res/`. Icône
  **adaptative** (foreground plein cadre, `adaptive_icon_background = #16213C` token `backgroundDeep`),
  **inset retiré** du `mipmap-anydpi-v26/ic_launcher.xml` pour remplir le cercle (le legacy seul donnait une
  bordure blanche sur Android 12). iOS : `AppIcon.appiconset` régénéré depuis la source 1024² **sans canal
  alpha** (rejet App Store sinon). `src/main` laissé intact.
- **Splash** : `flutter_native_splash` flavor (`flutter_native_splash-production.yaml`, logo carré sur
  `#16213C`) → `android/app/src/production/` (+ android12) et iOS `LaunchScreenProduction.storyboard`.
- **Nom** : retrait de « App ». Android `manifestPlaceholders["appName"]` ; iOS `FLAVOR_APP_NAME`
  (→ `CFBundleDisplayName`). `Digiharmony` / `[STG] Digiharmony` / `[DEV] Digiharmony`.

## Faits structurants (vérifiés)

- **iOS launch storyboard par flavor** : `INFOPLIST_KEY_UILaunchStoryboardName` est **ignoré** quand la clé
  existe déjà dans `Info.plist` (le fichier explicite gagne). Solution : `Info.plist` →
  `UILaunchStoryboardName = $(LAUNCH_STORYBOARD_NAME:default=LaunchScreen)`, puis `LAUNCH_STORYBOARD_NAME =
  LaunchScreenProduction` **uniquement** sur les 3 configs production. dev/staging retombent sur le défaut.
  Le storyboard doit être **ajouté au projet Xcode** (PBXFileReference + PBXBuildFile + phase Resources),
  sinon introuvable au runtime. → rule `3-flutter-ios-infoplist-key-build-variable`.
- **Outils = dev-dependencies** (build-time) : aucun impact runtime, aucune collecte, aucune permission.
- **Android `minify`/`shrinkResources` restent `false`** (DEC-001 / rule android-gradle-minify-off).

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Déposer les PNG legacy fournis dans `src/main` | rapide | casse les icônes adaptatives + bordure blanche Android 12 + impacte tous les flavors | pas production-only, rendu dégradé |
| Régénérer l'identité sur les 3 flavors | une seule config | perd la différenciation dev/staging en test | l'utilisateur veut prod seulement |
| Icône legacy plein cadre (sans adaptive) | « tel quel » | Android 12+ rétrécit sur fond blanc | rendu jugé moche |

## Consequences

- ✅ Builds Android prod+dev et iOS prod OK ; dev/staging visuellement inchangés.
- ✅ Régénérable : configs `flutter_launcher_icons-production.yaml` / `flutter_native_splash-production.yaml`
  + source `tool/icon/app_icon_1024.png` versionnées.
- ⚠️ Le visuel d'icône (plein cadre, éléments en bord) est **rogné** par les masques de lanceur (choix assumé).
- ⚠️ Contenu/branding restent à valider partenaires si évolution. [[deployment]] [[architecture]].
