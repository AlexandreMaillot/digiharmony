// DeviceActivityReportExtension.swift
// DigiHarmony — App Extension scaffold (INERT — pas de target Xcode actif)
//
// ⚠️  Ce répertoire est un SQUELETTE d'App Extension `DeviceActivityReportExtension`.
//     Il n'est PAS intégré à aucun target Xcode. Le target doit être créé
//     MANUELLEMENT dans Xcode (File > New > Target > Device Activity Report Extension)
//     APRÈS obtention de l'entitlement family-controls.
//
//     Voir ScreenTimeScaffold/README.md pour les étapes complètes.
//
// Fichiers à placer dans ce target une fois créé :
//   - DeviceActivityReportExtension.swift  (ce fichier — point d'entrée de la scène)
//   - TotalActivityView.swift              (vue SwiftUI du rapport)
//   - Info.plist                           (NSExtensionPointIdentifier requis)
//   - DeviceActivityReportExtension.entitlements (family-controls)

import DeviceActivity
import SwiftUI

// MARK: - DeviceActivityReportScene

/// Scène principale de l'extension de rapport.
///
/// Déclare le `context` `"digiharmony.today"` (à aligner avec l'hôte qui
/// construit le `DeviceActivityReport(context:)`).
@available(iOS 16.0, *)
struct DigiHarmonyReportScene: DeviceActivityReportScene {

    /// Contexte utilisé pour identifier ce rapport côté hôte.
    static let context = DeviceActivityReport.Context("digiharmony.today")

    /// Contenu rendu par le système dans le process sandboxé de l'extension.
    let content: (ActivityReport) -> TotalActivityView

    var body: some DeviceActivityReportScene {
        DeviceActivityReportScene(appActivitySegment: content)
    }
}

// MARK: - Rapport agrégé (modèle minimal)

/// Données agrégées calculées par le système, transmises à la vue de rapport.
///
/// Note : ces données NE TRAVERSENT PAS vers l'app hôte Flutter. Elles restent
/// dans le process sandboxé de l'extension (contrainte API Apple, DEC-TE-13).
@available(iOS 16.0, *)
struct ActivityReport {
    /// Durée totale d'utilisation d'écran sur la période demandée.
    let totalScreenTime: DateComponents

    /// Applications les plus utilisées (données fournies par le système).
    let topApps: [AppActivity]
}

/// Activité d'une app individuelle (données système, non accessibles à l'hôte).
@available(iOS 16.0, *)
struct AppActivity: Identifiable {
    let id = UUID()
    let displayName: String
    let duration: DateComponents
}
