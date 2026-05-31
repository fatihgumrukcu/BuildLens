import SwiftUI

struct DiagnosticSummaryHeader: View {
    let summary: DiagnosticSummary
    let isRescanning: Bool
    let onRescan: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MetricCard(
                title: "Critical",
                value: summary.criticalCount > 0 ? "\(summary.criticalCount)" : "None",
                icon: "xmark.circle.fill",
                tint: summary.criticalCount > 0 ? .statusError : .statusHealthy
            )
            MetricCard(
                title: "Warnings",
                value: summary.warningCount > 0 ? "\(summary.warningCount)" : "None",
                icon: "exclamationmark.triangle.fill",
                tint: summary.warningCount > 0 ? .statusWarning : .statusHealthy
            )
            MetricCard(
                title: "Affected Storage",
                value: summary.totalAffectedStorage > 0
                    ? summary.totalAffectedStorage.formattedBytes
                    : "—",
                icon: "internaldrive",
                tint: Color.textSecondary
            )
            MetricCard(
                title: "Reclaimable",
                value: summary.reclaimableStorage > 0
                    ? summary.reclaimableStorage.formattedBytes
                    : "—",
                icon: "arrow.down.circle",
                tint: summary.reclaimableStorage > 0 ? .statusWarning : .statusHealthy
            )

            Spacer()

            Button(action: onRescan) {
                if isRescanning {
                    ProgressView().controlSize(.small)
                } else {
                    Label("Rescan", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isRescanning)
        }
        .padding(AppSpacing.contentPadding)
        .background(Color.appBackground)
    }
}
