import SwiftUI

// Four-card overview row — one card per key metric.
// Reuses MetricCard from Shared so visual language matches Dashboard and DerivedData.
struct SimulatorSummaryCards: View {
    let summary: SimulatorSummary

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 4
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
            MetricCard(
                title: "Devices",
                value: "\(summary.totalDevices)",
                icon: "iphone",
                tint: .blue
            )
            MetricCard(
                title: "Unavailable",
                value: "\(summary.unavailableDevices)",
                icon: "exclamationmark.triangle",
                tint: summary.unavailableDevices > 0 ? .statusWarning : .statusUnknown
            )
            MetricCard(
                title: "Storage",
                value: summary.totalStorageUsage.formattedBytes,
                icon: "internaldrive",
                tint: .purple
            )
            MetricCard(
                title: "Runtimes",
                value: "\(summary.activeRuntimeCount)",
                icon: "cpu",
                tint: .green
            )
        }
    }
}
