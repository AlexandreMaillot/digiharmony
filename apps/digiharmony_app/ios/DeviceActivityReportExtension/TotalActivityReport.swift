//
//  TotalActivityReport.swift
//  DeviceActivityReportExtension
//
//  Created by Alexandre MAILLOT on 06/06/2026.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

extension DeviceActivityReport.Context {
    /// Context key shared with the host's DeviceActivityReportViewFactory.
    /// Must match the string passed to DeviceActivityReport.Context in AppDelegate.swift.
    static let digiharmonyToday = Self("digiharmony.today")
}

/// Reports today's total device-activity duration.
///
/// Rendered by the system in this extension's sandboxed process — the host
/// app never reads usage numbers (DEC-TE-13, zero-collection guarantee).
struct TotalActivityReport: DeviceActivityReportScene {
    /// Must match DeviceActivityReport.Context("digiharmony.today") in AppDelegate.swift.
    let context: DeviceActivityReport.Context = .digiharmonyToday

    let content: (String) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll

        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0) {
            $0 + $1.totalActivityDuration
        }
        return formatter.string(from: totalActivityDuration) ?? "—"
    }
}
