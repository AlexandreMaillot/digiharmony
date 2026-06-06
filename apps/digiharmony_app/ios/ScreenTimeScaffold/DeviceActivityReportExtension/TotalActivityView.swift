// TotalActivityView.swift
// DigiHarmony — vue SwiftUI du rapport de temps d'écran (INERT — pas de target actif)
//
// ⚠️  Voir DeviceActivityReportExtension.swift et README.md pour les étapes
//     d'activation (création du target Xcode + entitlement family-controls).

import DeviceActivity
import SwiftUI

/// Vue SwiftUI minimale rendue par le système dans le process sandboxé de
/// l'extension `DeviceActivityReportExtension`.
///
/// Affiche le temps d'écran total du jour. La mise en forme et les données
/// restent dans l'extension (jamais accessibles à l'app hôte Flutter).
///
/// Style sobre, cohérent au mieux avec le ton bienveillant DigiHarmony.
/// Note : le contrôle design est limité côté extension (la vue est rendue par
/// le système dans un process séparé) — c'est une contrainte d'API Apple
/// documentée (DEC-TE-16).
@available(iOS 16.0, *)
struct TotalActivityView: View {

    let report: ActivityReport

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Titre sobre (évite les scores/objectifs/FOMO — ton bienveillant)
            Text("Aujourd'hui")
                .font(.headline)
                .foregroundColor(.primary)

            // Durée totale
            HStack {
                Image(systemName: "clock")
                    .accessibilityHidden(true)
                Text(formatterDuree(report.totalScreenTime))
                    .font(.title2.bold())
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Temps d'écran total : \(formatterDuree(report.totalScreenTime))"
            )

            // Liste top apps (données système — non transmises à l'hôte)
            if !report.topApps.isEmpty {
                Divider()
                ForEach(report.topApps) { app in
                    HStack {
                        Text(app.displayName)
                            .font(.body)
                        Spacer()
                        Text(formatterDuree(app.duration))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        "\(app.displayName) : \(formatterDuree(app.duration))"
                    )
                }
            }

            Spacer()

            // Note de confidentialité (cohérente avec DEC-TE-13 : données non
            // transmises à l'app hôte)
            Text("Ces données restent dans ton iPhone, l'app ne les voit pas.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }

    // MARK: - Formatage durée (DateComponents → String lisible)

    private func formatterDuree(_ components: DateComponents) -> String {
        let heures = components.hour ?? 0
        let minutes = components.minute ?? 0
        if heures > 0 {
            return "\(heures) h \(minutes) min"
        }
        return "\(minutes) min"
    }
}
