//
//  TotalActivityView.swift
//  DeviceActivityReportExtension
//
//  Created by Alexandre MAILLOT on 06/06/2026.
//

import SwiftUI

/// Displays today's total screen-time duration.
///
/// Rendered by the system inside the DeviceActivityReportExtension process —
/// the host app never reads this value (DEC-TE-13, zero-collection guarantee).
/// The a11y of this view is owned by the system (partially uncontrollable —
/// documented in DEC-TE-16 as an accepted limitation).
struct TotalActivityView: View {
    let totalActivity: String

    var body: some View {
        VStack(spacing: 8) {
            Text(totalActivity)
                .font(.largeTitle.bold())
                .accessibilityLabel(totalActivity)
            Text("aujourd'hui")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    TotalActivityView(totalActivity: "1h 23m")
}
