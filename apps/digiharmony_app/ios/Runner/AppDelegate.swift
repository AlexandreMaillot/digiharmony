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
  private let hostingController: UIViewController

  init(frame: CGRect, messenger: FlutterBinaryMessenger, viewId: Int64) {
    // MVP filter: today's daily segment (DEC-TE-16).
    let todayInterval = Calendar.current.dateInterval(of: .day, for: Date())!
    let filter = DeviceActivityFilter(
      segment: .daily(during: todayInterval)
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
