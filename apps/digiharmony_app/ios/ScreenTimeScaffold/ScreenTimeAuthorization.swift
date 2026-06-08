// ScreenTimeAuthorization.swift
// DigiHarmony — iOS Screen Time scaffolding (INERT — NOT compiled into Runner)
//
// ⚠️  NE PAS ajouter au target Runner tant que l'entitlement
//     com.apple.developer.family-controls n'est pas accordé par Apple et
//     intégré au provisioning profile. Ce fichier EST INTENTIONNELLEMENT
//     hors de tout target Xcode pour ne pas casser le build.
//
// Activation (étapes humaines) :
//   1. Obtenir l'entitlement family-controls (portail Apple Developer).
//   2. Regénérer les provisioning profiles (Runner + extension, 3 flavors).
//   3. Dans Xcode, activer la capability "Screen Time" sur le target Runner
//      (génère/édite Runner/Runner.entitlements).
//   4. Ajouter CE fichier au target Runner (Build Phases > Compile Sources).
//   5. Mettre kScreenTimeIosActif = true dans screen_time_ios_channel.dart.
//   Voir ScreenTimeScaffold/README.md pour le détail complet.

import Flutter
import FamilyControls

/// Enregistre et gère le MethodChannel `digiharmony/screen_time`.
///
/// Expose deux méthodes :
///   - `statutAutorisation` : lecture silencieuse du statut FamilyControls
///     (ne déclenche pas de pop-up système).
///   - `demanderAutorisation` : déclenche
///     `AuthorizationCenter.shared.requestAuthorization(for: .individual)`
///     (à n'appeler qu'après que l'utilisateur a explicitement tapé le CTA).
///
/// En cas d'erreur (entitlement absent, API indisponible, iOS < cible) la
/// méthode retourne `"indisponible"` plutôt que de crasher.
@available(iOS 16.0, *)
class ScreenTimeAuthorizationChannel: NSObject {

    private static let channelName = "digiharmony/screen_time"
    private let channel: FlutterMethodChannel

    init(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: ScreenTimeAuthorizationChannel.channelName,
            binaryMessenger: binaryMessenger
        )
        super.init()
        channel.setMethodCallHandler(handleMethodCall)
    }

    // MARK: - Handler principal

    private func handleMethodCall(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "statutAutorisation":
            result(statutCourantString())
        case "demanderAutorisation":
            Task {
                let statut = await demanderAutorisation()
                result(statut)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Lecture silencieuse du statut

    /// Lit `AuthorizationCenter.shared.authorizationStatus` sans déclencher
    /// de pop-up. Retourne une String compatible côté Dart.
    private func statutCourantString() -> String {
        let status = AuthorizationCenter.shared.authorizationStatus
        return mapStatut(status)
    }

    // MARK: - Demande d'autorisation (explicite, sur CTA utilisateur)

    /// Appelle `requestAuthorization(for: .individual)`.
    /// - Retourne le statut résultant sous forme de String.
    /// - Capture toute erreur → `"indisponible"` (jamais de crash).
    private func demanderAutorisation() async -> String {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            return mapStatut(AuthorizationCenter.shared.authorizationStatus)
        } catch {
            // Entitlement absent, refus système ou API indisponible.
            return "indisponible"
        }
    }

    // MARK: - Mapping enum → String (contrat Dart)

    private func mapStatut(_ status: AuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "nonDemande"
        case .denied:
            return "refuse"
        case .approved:
            return "accorde"
        @unknown default:
            return "indisponible"
        }
    }
}

// MARK: - Point d'entrée (à appeler depuis AppDelegate après activation)
//
// Exemple d'intégration dans AppDelegate.swift (APRÈS activation) :
//
//   import Flutter
//   @UIApplicationMain
//   @objc class AppDelegate: FlutterAppDelegate {
//       private var screenTimeChannel: ScreenTimeAuthorizationChannel?
//       override func application(
//           _ application: UIApplication,
//           didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//       ) -> Bool {
//           let controller = window?.rootViewController as! FlutterViewController
//           screenTimeChannel = ScreenTimeAuthorizationChannel(
//               binaryMessenger: controller.binaryMessenger
//           )
//           return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//       }
//   }
