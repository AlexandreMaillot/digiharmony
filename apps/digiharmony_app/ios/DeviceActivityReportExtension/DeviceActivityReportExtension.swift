//
//  DeviceActivityReportExtension.swift
//  DeviceActivityReportExtension
//
//  Created by Alexandre MAILLOT on 06/06/2026.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

/// Entry point for the DeviceActivityReport extension.
///
/// Declares the TotalActivityReport scene for the "digiharmony.today" context.
/// The system renders this in a sandboxed process — the host app never reads
/// usage numbers (DEC-TE-13, zero-collection guarantee).
@main
struct DigiHarmonyActivityReportExtension: DeviceActivity.DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Declares our "digiharmony.today" report scene.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
    }
}
