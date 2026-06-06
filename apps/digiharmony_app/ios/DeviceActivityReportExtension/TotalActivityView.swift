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

    /// Localized "today" subtitle in the 8 project languages (fallback EN).
    ///
    /// The extension target carries no `.strings` bundle; we resolve the word
    /// from the current locale here so the subtitle is not hardcoded in French
    /// for EN/EL/IT/RO/TR/ES/MK users (review finding #3).
    private var todayLabel: String {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        switch code {
        case "fr": return "aujourd'hui"
        case "el": return "σήμερα"
        case "it": return "oggi"
        case "ro": return "astăzi"
        case "tr": return "bugün"
        case "es": return "hoy"
        case "mk": return "денес"
        default: return "today"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(totalActivity)
                .font(.largeTitle.bold())
                .accessibilityLabel(totalActivity)
            Text(todayLabel)
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
