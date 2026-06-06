# Decision: Support iOS du temps d'écran via Apple Screen Time (FamilyControls + DeviceActivityReport)

| Field   | Value                  |
| ------- | ---------------------- |
| ID      | DEC-006                |
| Date    | 2026-06-06             |
| Feature | Mon temps d'écran (iOS) |
| Status  | Accepted               |

## Context

Android lit l'usage via `UsageStatsManager` (perm `PACKAGE_USAGE_STATS`). iOS **ne donne aucun accès
libre** au temps d'écran (`app_usage` renvoie `[]`). L'objectif est d'offrir le temps d'écran sur
iPhone aussi, sans collecte.

## Decision

Utiliser l'**API Apple Screen Time** : autorisation **`FamilyControls`** (`AuthorizationCenter
.requestAuthorization(for: .individual)`) exposée via un **MethodChannel `digiharmony/screen_time`
câblé dans `AppDelegate`** (pattern implicit-engine `didInitializeImplicitFlutterEngine`), et
affichage via une **App Extension `DeviceActivityReport`** (vue SwiftUI **rendue par le système**)
intégrée côté Flutter en **PlatformView `digiharmony/device_activity_report`**. Activation derrière le
flag Dart `kScreenTimeIosActif` ; façade `ServiceTempsEcranIos`. Android **inchangé**.

## Faits structurants (vérifiés)

- **Capability « Family Controls (Development) » = SANS approbation Apple** (dev/test sur device
  enregistré). La **Distribution** (App Store/TestFlight) exige la demande de l'entitlement
  `com.apple.developer.family-controls` (form `developer.apple.com/contact/request/family-controls-distribution`,
  validation Apple au cas par cas). ⚠️ Corrige une hypothèse initiale fausse (« rien ne build sans
  approbation »).
- **Les chiffres ne sont JAMAIS lisibles par l'app** : le `DeviceActivityReport` est rendu dans une
  extension sandboxée → **pas d'historique Drift iOS, pas de top-apps custom iOS** (UX iOS ≠ maquette
  Android jauge/semaine).
- **Bundle id de l'extension préfixé par le host, par flavor** (`com.creappi.digiharmony.dev.DeviceActivityReportExtension`, etc.) sinon erreur « not prefixed with parent app ».
- **Xcode build phases** : « Embed ExtensionKit Extensions » doit précéder le script Flutter « Thin
  Binary » (sinon « Cycle inside Runner »).
- Pas de simulateur (Screen Time = device réel).

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Package `app_usage` sur iOS | uniforme avec Android | renvoie `[]` (pas d'accès iOS) | ne fonctionne pas |
| Saisie manuelle du temps | aucune contrainte Apple | faux, non fiable | hors esprit projet |
| iOS = « indisponible » définitif | zéro effort | pas de temps d'écran iPhone | l'utilisateur veut iOS |

## Consequences

- ✅ `flutter build ios` compile ; la plomberie est prête (`5948017`).
- ⚠️ **Runtime** : nécessite l'entitlement ; la capability **Development suffit pour tester** sur
  device, **Distribution** requiert l'approbation Apple (bloquant App Store, hors code).
- ⚠️ **UX iOS** = rapport Apple embarqué (pas la jauge/graphe Android).
- ⚠️ Bundle ids extension **staging/production** encore non préfixés → à corriger au provisioning.
- 🔗 Plan détaillé : `aidd_docs/plans/temps-ecran-ios-screentime.plan.md` ; scaffold + README dans
  `apps/digiharmony_app/ios/ScreenTimeScaffold/`. [[architecture]].
