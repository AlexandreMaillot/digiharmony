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

/// One day's total activity — feeds the 7-day mini chart.
struct DayUsage: Identifiable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    let isToday: Bool
}

/// Aggregated data handed to `TotalActivityView`.
///
/// Computed inside the sandboxed extension process — the host app never reads
/// these numbers (DEC-TE-13, zero-collection guarantee).
struct ActivityReport {
    /// Total activity for today (so far).
    let todayDuration: TimeInterval

    /// Last 7 days, chronological (J-6 → today). Missing days = 0.
    let days: [DayUsage]

    /// Sum of the 7 days.
    let weekDuration: TimeInterval
}

/// Reports today's total + a 7-day breakdown of device activity.
///
/// Rendered by the system in this extension's sandboxed process — the host
/// app never reads usage numbers (DEC-TE-13, zero-collection guarantee).
struct TotalActivityReport: DeviceActivityReportScene {
    /// Must match DeviceActivityReport.Context("digiharmony.today") in AppDelegate.swift.
    let context: DeviceActivityReport.Context = .digiharmonyToday

    let content: (ActivityReport) -> TotalActivityView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> ActivityReport {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())

        // Somme de la durée d'activité par jour.
        var perDay: [Date: TimeInterval] = [:]
        for await datum in data {
            for await segment in datum.activitySegments {
                let day = cal.startOfDay(for: segment.dateInterval.start)
                perDay[day, default: 0] += segment.totalActivityDuration
            }
        }

        // Construit 7 entrées (J-6 … aujourd'hui) ; jours manquants = 0.
        var days: [DayUsage] = []
        for offset in stride(from: 6, through: 0, by: -1) {
            let day = cal.date(byAdding: .day, value: -offset, to: startOfToday) ?? startOfToday
            days.append(
                DayUsage(
                    date: day,
                    duration: perDay[day] ?? 0,
                    isToday: offset == 0
                )
            )
        }

        return ActivityReport(
            todayDuration: perDay[startOfToday] ?? 0,
            days: days,
            weekDuration: days.reduce(0) { $0 + $1.duration }
        )
    }
}
