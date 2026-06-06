# ScreenTimeScaffold — Activation iOS Screen Time

> Ce répertoire contient la plomberie Swift INERTE pour le support iOS de l'écran
> « Mon temps d'écran » via l'API Apple Screen Time (FamilyControls / DeviceActivity).
> **Rien ici n'est compilé ni actif.** Les fichiers sont hors de tout target Xcode.
>
> Plan de référence : `aidd_docs/plans/temps-ecran-ios-screentime.plan.md`

---

## Prérequis bloquants (humains, hors code)

Ces étapes sont **non automatisables** et **bloquantes** dans l'ordre indiqué.

### Étape 1 — Obtenir l'entitlement Apple (BLOQUANT RACINE)

L'entitlement `com.apple.developer.family-controls` est un **accès spécial Apple**,
accordé au cas par cas via le portail développeur Apple.

- URL : https://developer.apple.com/contact/request/screentime-framework
- Justification à préparer : usage bien-être, public mineur, aucune surveillance
  parentale, aucune collecte de données.
- Délai et issue **incertains**. Tant que non accordé : le build iOS avec ce code
  échouera à la signature / exécution.

### Étape 2 — Regénérer les provisioning profiles

Après accord Apple :
- Regénérer les provisioning profiles pour les **3 flavors** (development, staging,
  production) du target **Runner**, en incluant l'entitlement `family-controls`.
- Créer des profils **dédiés pour l'extension** `DeviceActivityReportExtension`
  (bundle id = suffixe du bundle id hôte, voir Étape 4).

---

## Étapes d'activation dans Xcode

### Étape 3 — Activer la capability Screen Time sur le target Runner

1. Ouvrir `Runner.xcodeproj` dans Xcode.
2. Sélectionner le target **Runner** > **Signing & Capabilities**.
3. Cliquer **+ Capability** > chercher **Screen Time**.
4. Xcode génère (ou édite) `Runner/Runner.entitlements` avec :
   ```xml
   <key>com.apple.developer.family-controls</key>
   <true/>
   ```
5. **Ne PAS** modifier `Runner/Runner.entitlements` à la main avant cette étape
   (risque de conflit de provisioning).

### Étape 4 — Créer le target App Extension DeviceActivityReportExtension

> Cette étape est la plus délicate — à faire dans Xcode, pas en CLI.

1. Dans Xcode : **File > New > Target**.
2. Chercher **Device Activity Report Extension** dans les templates.
3. Nom du target : `DeviceActivityReportExtension`.
4. Bundle identifiers par flavor (DOIT être un suffixe du bundle id hôte) :
   - development  : `<host_bundle_id_dev>.devicereport`
   - staging      : `<host_bundle_id_staging>.devicereport`
   - production   : `<host_bundle_id_prod>.devicereport`
5. **Remplacer** les fichiers Swift générés par Xcode par ceux de ce répertoire :
   - `DeviceActivityReportExtension/DeviceActivityReportExtension.swift`
   - `DeviceActivityReportExtension/TotalActivityView.swift`
6. Câbler `DeviceActivityReportExtension/Info.plist` au target (ajuster les
   bundle ids et `NSExtensionPrincipalClass`).
7. Câbler `DeviceActivityReportExtension/DeviceActivityReportExtension.entitlements`
   au target (Build Settings > Code Signing Entitlements).

### Étape 5 — Activer FamilyControls sur le target d'extension

1. Sélectionner le target **DeviceActivityReportExtension** > **Signing & Capabilities**.
2. Cliquer **+ Capability** > **Screen Time**.
3. Vérifier que le profil de provisioning de l'extension inclut `family-controls`.

### Étape 6 — Ajouter ScreenTimeAuthorization.swift au target Runner

1. Dans Xcode, sélectionner le target **Runner** > **Build Phases > Compile Sources**.
2. Cliquer **+** et ajouter `ScreenTimeScaffold/ScreenTimeAuthorization.swift`.
3. **Ne pas** déplacer le fichier dans `ios/Runner/` (pour garder la séparation
   scaffold / code compilé propre).

### Étape 7 — Câbler ScreenTimeAuthorization dans AppDelegate.swift

Ajouter dans `ios/Runner/AppDelegate.swift` :

```swift
import Flutter
// ⚠️ Décommenter après l'étape 6 :
// import FamilyControls

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    // ⚠️ Décommenter après l'étape 6 :
    // private var screenTimeChannel: ScreenTimeAuthorizationChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController

        // ⚠️ Décommenter après l'étape 6 :
        // screenTimeChannel = ScreenTimeAuthorizationChannel(
        //     binaryMessenger: controller.binaryMessenger
        // )

        // TODO (étape 8) : enregistrer DeviceActivityReportViewFactory ici.

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### Étape 8 — Créer et enregistrer DeviceActivityReportViewFactory (PlatformView)

Créer `ios/Runner/DeviceActivityReportViewFactory.swift` (hors scaffold, dans le
target Runner) avec le contenu suivant, puis l'ajouter à **Build Phases > Compile
Sources** :

```swift
import Flutter
import DeviceActivity
import SwiftUI

@available(iOS 16.0, *)
class DeviceActivityReportViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64,
                arguments args: Any?) -> FlutterPlatformView {
        DeviceActivityReportPlatformView(frame: frame, messenger: messenger,
                                         viewId: viewId)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 16.0, *)
class DeviceActivityReportPlatformView: NSObject, FlutterPlatformView {
    private let hostingController: UIViewController

    init(frame: CGRect, messenger: FlutterBinaryMessenger, viewId: Int64) {
        // Filtre MVP : segment "aujourd'hui" (DEC-TE-16)
        let filter = DeviceActivityFilter(
            segment: .daily(during: Calendar.current.dateInterval(
                of: .day, for: Date()
            )!)
        )
        let reportView = DeviceActivityReport(
            DeviceActivityReport.Context("digiharmony.today"),
            filter: filter
        )
        hostingController = UIHostingController(rootView: reportView)
        super.init()
    }

    func view() -> UIView { hostingController.view }
}
```

Puis dans `AppDelegate.swift`, enregistrer la factory :

```swift
registrar(forPlugin: "").register(
    DeviceActivityReportViewFactory(messenger: controller.binaryMessenger),
    withId: "digiharmony/device_activity_report"
)
```

---

## Étape 9 — Activer la plomberie Dart

Dans `lib/pages/temps_ecran/services/screen_time_ios_channel.dart` :

```dart
// Passer de :
const bool kScreenTimeIosActif = false;
// à :
const bool kScreenTimeIosActif = true;
```

Cela permettra au `ServiceTempsEcranIos` (à créer dans M1 du plan) de router
vers le channel natif au lieu de retourner `indisponible`.

---

## Validation après activation

Depuis `apps/digiharmony_app/` :

```bash
flutter gen-l10n
dart analyze --fatal-infos    # 0 warning/info
flutter test                  # tous les tests verts
flutter build ios --release --no-codesign  # BLOQUÉ sans entitlement provisioning
```

La validation de bout en bout (autorisation accordée, rapport affiché) exige un
**iPhone physique** connecté (Screen Time indisponible en simulateur).

---

## Référence

- Plan complet : `aidd_docs/plans/temps-ecran-ios-screentime.plan.md`
- Décisions : DEC-TE-03 (révisée), DEC-TE-12, DEC-TE-13, DEC-TE-14, DEC-TE-15, DEC-TE-16
- Documentation Apple :
  - https://developer.apple.com/documentation/familycontrols
  - https://developer.apple.com/documentation/deviceactivity
