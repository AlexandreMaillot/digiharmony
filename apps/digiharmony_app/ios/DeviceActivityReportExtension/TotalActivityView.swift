//
//  TotalActivityView.swift
//  DeviceActivityReportExtension
//
//  Created by Alexandre MAILLOT on 06/06/2026.
//

import SwiftUI

/// Displays today's screen-time as a circular gauge + a 7-day mini chart.
///
/// Mirrors the spirit of the Android Flutter view (`VueResume`) — gauge with
/// the day's total at the center, then a weekly bar chart — but rendered in
/// SwiftUI inside the DeviceActivityReportExtension process. The host app never
/// reads these values (DEC-TE-13, zero-collection guarantee). The a11y is
/// partly owned by the system (DEC-TE-16, accepted limitation).
struct TotalActivityView: View {
    let report: ActivityReport

    // Palette alignée sur AppColors (thème sombre de l'app). L'extension ne
    // partage pas le thème Flutter : on reproduit donc les teintes ici.
    private static let textColor = Color(red: 0.949, green: 0.965, blue: 0.984) // #F2F6FB
    private static let muted = Color(red: 0.655, green: 0.714, blue: 0.808)   // #A7B6CE
    private static let primary = Color(red: 0.247, green: 0.722, blue: 0.902) // #3FB8E6
    private static let primaryLight = Color(red: 0.561, green: 0.847, blue: 0.941) // #8FD8F0
    private static let green = Color(red: 0.204, green: 0.780, blue: 0.349)   // #34C759

    /// 8 h = jauge pleine. Neutre/informatif, jamais culpabilisant (DEC-TE-09).
    private static let dailyCap: TimeInterval = 8 * 3600

    private var fraction: Double {
        guard Self.dailyCap > 0 else { return 0 }
        return min(report.todayDuration / Self.dailyCap, 1)
    }

    private var maxDayDuration: TimeInterval {
        max(report.days.map(\.duration).max() ?? 0, 1)
    }

    var body: some View {
        VStack(spacing: 20) {
            jauge
            ligneSemaine
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        // Fond transparent : laisse voir le fond (halo) de la page Flutter.
        .background(Color.clear)
    }

    // MARK: - Ligne semaine (total à gauche, barres à droite — façon Android)

    private var ligneSemaine: some View {
        HStack(alignment: .bottom, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(format(report.weekDuration))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Self.primary)
                Text(weekLabel)
                    .font(.caption)
                    .foregroundStyle(Self.muted)
            }
            Spacer(minLength: 8)
            grapheSemaine
        }
    }

    // MARK: - Jauge circulaire

    private var jauge: some View {
        ZStack {
            Circle()
                .stroke(Self.primary.opacity(0.15), lineWidth: 16)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Self.primaryLight, Self.primary, Self.green]),
                        center: .center,
                        startAngle: .degrees(-90),
                        // Le dégradé est compressé dans l'arc rempli (comme la
                        // jauge Android) : cyan→vert visible même à faible taux.
                        endAngle: .degrees(-90 + 360 * fraction)
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text(format(report.todayDuration))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Self.textColor)
                Text(todayLabel)
                    .font(.subheadline)
                    .foregroundStyle(Self.muted)
            }
        }
        .frame(width: 180, height: 180)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(format(report.todayDuration)) \(todayLabel)")
    }

    // MARK: - Mini-graphe 7 jours

    private var grapheSemaine: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(report.days) { day in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(day.isToday ? Self.primary : Self.primaryLight.opacity(0.5))
                        .frame(width: 14, height: barHeight(day))
                    Text(dayInitial(day.date))
                        .font(.system(size: 10, weight: day.isToday ? .bold : .regular))
                        .foregroundStyle(day.isToday ? Self.primary : Self.muted)
                }
            }
        }
        .frame(height: 70, alignment: .bottom)
    }

    private func barHeight(_ day: DayUsage) -> CGFloat {
        let minH: CGFloat = 4
        let maxH: CGFloat = 48
        let frac = day.duration / maxDayDuration
        return minH + (maxH - minH) * CGFloat(frac)
    }

    // MARK: - Helpers

    /// Formate une durée en « 1h 23m » (locale-aware, abrégé).
    private func format(_ duration: TimeInterval) -> String {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .abbreviated
        f.zeroFormattingBehavior = .dropAll
        let s = f.string(from: duration) ?? ""
        return s.isEmpty ? "0m" : s
    }

    /// Initiale du jour (1 lettre, locale-aware) — ex. L M M J V S D.
    private func dayInitial(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("EEEEE")
        return f.string(from: date)
    }

    /// Sous-titre « aujourd'hui » dans les 8 langues du projet (repli EN).
    private var todayLabel: String {
        switch Locale.current.language.languageCode?.identifier {
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

    /// Libellé « cette semaine » dans les 8 langues du projet (repli EN).
    private var weekLabel: String {
        switch Locale.current.language.languageCode?.identifier {
        case "fr": return "cette semaine"
        case "el": return "αυτή την εβδομάδα"
        case "it": return "questa settimana"
        case "ro": return "săptămâna aceasta"
        case "tr": return "bu hafta"
        case "es": return "esta semana"
        case "mk": return "оваа недела"
        default: return "this week"
        }
    }
}

#Preview {
    TotalActivityView(
        report: ActivityReport(
            todayDuration: 2 * 3600 + 14 * 60,
            days: (0...6).map { offset in
                DayUsage(
                    date: Calendar.current.date(byAdding: .day, value: -6 + offset, to: Date())!,
                    duration: TimeInterval((offset + 1) * 1800),
                    isToday: offset == 6
                )
            },
            weekDuration: 7 * 3600
        )
    )
}
