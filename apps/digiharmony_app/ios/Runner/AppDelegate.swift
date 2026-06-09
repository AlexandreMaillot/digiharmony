import DeviceActivity
import FamilyControls
import Flutter
import SwiftUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  // Retained strongly so the channel handler stays alive.
  private var screenTimeChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "")!.messenger()

    // ── MethodChannel digiharmony/screen_time ────────────────────────────────
    // Exposes:
    //   • statutAutorisation()   — silent read of FamilyControls status
    //   • demanderAutorisation() — triggers the system authorization dialog
    //     (only called after explicit user CTA — DEC-TE-15).
    // Requires entitlement com.apple.developer.family-controls (Apple special
    // access). Any error → "indisponible", never a crash (parity with Android).
    if #available(iOS 16.0, *) {
      let channel = FlutterMethodChannel(
        name: "digiharmony/screen_time",
        binaryMessenger: messenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "statutAutorisation":
          result(AppDelegate.statutCourantString())
        case "demanderAutorisation":
          Task {
            let statut = await AppDelegate.demanderAutorisationAsync()
            result(statut)
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      screenTimeChannel = channel

      // ── PlatformView digiharmony/device_activity_report ──────────────────
      // Embeds a UIHostingController(DeviceActivityReport) whose content is
      // rendered by the DeviceActivityReportExtension process (sandboxed —
      // the host never reads usage numbers — DEC-TE-13).
      let registrar = engineBridge.pluginRegistry.registrar(
        forPlugin: "DeviceActivityReportViewFactory"
      )!
      registrar.register(
        DeviceActivityReportViewFactory(messenger: messenger),
        withId: "digiharmony/device_activity_report"
      )
    }
  }

  // MARK: - FamilyControls helpers

  @available(iOS 16.0, *)
  private static func statutCourantString() -> String {
    mapStatut(AuthorizationCenter.shared.authorizationStatus)
  }

  @available(iOS 16.0, *)
  private static func demanderAutorisationAsync() async -> String {
    do {
      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
      return mapStatut(AuthorizationCenter.shared.authorizationStatus)
    } catch {
      // Entitlement absent, system refusal, or API unavailable.
      return "indisponible"
    }
  }

  @available(iOS 16.0, *)
  private static func mapStatut(_ status: AuthorizationStatus) -> String {
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

// MARK: - PlatformView factory (DeviceActivityReport)

/// Registers the DeviceActivityReport PlatformView under
/// "digiharmony/device_activity_report".
///
/// The UIHostingController hosts a DeviceActivityReport whose *content* is
/// rendered by the DeviceActivityReportExtension process — the host reads
/// nothing (DEC-TE-13).
///
/// Minimum deployment: iOS 16 (DeviceActivity framework requirement).
@available(iOS 16.0, *)
class DeviceActivityReportViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    DeviceActivityReportPlatformView(frame: frame, messenger: messenger, viewId: viewId)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

@available(iOS 16.0, *)
class DeviceActivityReportPlatformView: NSObject, FlutterPlatformView {
  private let container: ReportContainerView

  init(frame: CGRect, messenger: FlutterBinaryMessenger, viewId: Int64) {
    // Fenêtre 7 jours (J-6 → maintenant), segmentée par jour : alimente la
    // jauge du jour + le mini-graphe hebdomadaire côté extension (DEC-TE-16).
    let cal = Calendar.current
    let startOfToday = cal.startOfDay(for: Date())
    let weekStart = cal.date(byAdding: .day, value: -6, to: startOfToday)!
    let weekInterval = DateInterval(start: weekStart, end: Date())
    let filter = DeviceActivityFilter(
      segment: .daily(during: weekInterval)
    )
    let reportView = DeviceActivityReport(
      DeviceActivityReport.Context("digiharmony.today"),
      filter: filter
    )
    let host = UIHostingController(rootView: reportView)
    // Fond transparent : sinon le hosting controller affiche un fond blanc
    // opaque par-dessus le thème sombre de l'app.
    host.view.backgroundColor = .clear
    container = ReportContainerView(host: host, frame: frame)
    super.init()
    NSLog(
      "[DigiHarmony][ScreenTime] PlatformView créée (viewId=\(viewId), frame=\(frame))"
    )
  }

  func view() -> UIView { container }
}

/// Conteneur qui héberge le `DeviceActivityReport` et le rattache au view
/// controller parent dès l'entrée dans la fenêtre.
///
/// Sans ce rattachement à la hiérarchie de VC, le rendu système du rapport
/// (via XPC vers l'extension) ne démarre pas et la vue reste blanche.
@available(iOS 16.0, *)
final class ReportContainerView: UIView {
  private let host: UIHostingController<DeviceActivityReport>
  private var attached = false

  init(host: UIHostingController<DeviceActivityReport>, frame: CGRect) {
    self.host = host
    super.init(frame: frame)
    backgroundColor = .clear
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) non utilisé") }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    attacherSiPossible()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // Filet de securite : au PREMIER affichage, la hierarchie de view
    // controllers n'est pas toujours prete dans didMoveToWindow (le VC parent
    // est introuvable -> rapport blanc tant qu'on ne quitte/revient pas).
    // layoutSubviews se redeclenche une fois la vue posee dans la hierarchie :
    // on (re)tente le rattachement ici. Idempotent (guard `attached`).
    attacherSiPossible()
    host.view.frame = bounds
  }

  private func attacherSiPossible() {
    guard !attached, window != nil, let parent = parentViewController else {
      return
    }
    attached = true
    parent.addChild(host)
    host.view.frame = bounds
    host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(host.view)
    host.didMove(toParent: parent)
    NSLog(
      "[DigiHarmony][ScreenTime] Rapport rattaché à \(type(of: parent)) (bounds=\(bounds))"
    )
  }
}

private extension UIView {
  /// Remonte la chaîne des responders pour trouver le view controller hôte.
  var parentViewController: UIViewController? {
    var responder: UIResponder? = next
    while let current = responder {
      if let vc = current as? UIViewController { return vc }
      responder = current.next
    }
    return nil
  }
}
