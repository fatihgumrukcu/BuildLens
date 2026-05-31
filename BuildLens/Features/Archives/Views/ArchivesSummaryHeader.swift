import SwiftUI

struct ArchivesSummaryHeader: View {
    let summary: ArchiveSummary
    let onRescan: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MetricCard(
                title: "Total Archives",
                value: "\(summary.totalArchives)",
                icon: "archivebox",
                tint: .accentColor
            )
            MetricCard(
                title: "Total Storage",
                value: summary.totalStorage > 0 ? summary.totalStorage.formattedBytes : "—",
                icon: "internaldrive",
                tint: sizeColor
            )
            MetricCard(
                title: "Reclaimable",
                value: summary.reclaimableStorage > 0
                    ? summary.reclaimableStorage.formattedBytes
                    : "—",
                icon: "arrow.down.circle",
                tint: summary.reclaimableStorage > 0 ? .statusWarning : .statusHealthy
            )
            MetricCard(
                title: "Duplicate Groups",
                value: summary.duplicateArchives > 0 ? "\(summary.duplicateArchives)" : "None",
                icon: "doc.on.doc",
                tint: summary.duplicateArchives > 0 ? .statusWarning : .statusHealthy
            )

            Spacer()

            Button(action: onRescan) {
                Label("Rescan", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding(AppSpacing.contentPadding)
        .background(Color.appBackground)
    }

    private var sizeColor: Color {
        if summary.totalStorage >= 50 * 1_073_741_824 { return .statusError }
        if summary.totalStorage >= 20 * 1_073_741_824 { return .statusWarning }
        return Color.textSecondary
    }
}
