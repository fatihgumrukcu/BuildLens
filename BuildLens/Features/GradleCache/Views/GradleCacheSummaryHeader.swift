import SwiftUI

struct GradleCacheSummaryHeader: View {
    let summary: GradleCacheSummary
    let entryCount: Int
    let isRescanning: Bool
    let onRescan: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MetricCard(
                title: "Total Size",
                value: summary.totalCacheSize > 0
                    ? summary.totalCacheSize.formattedBytes
                    : "Empty",
                icon: "square.stack.3d.down.right.fill",
                tint: sizeColor
            )
            MetricCard(
                title: "Cache Entries",
                value: "\(entryCount)",
                icon: "folder.grid",
                tint: .accentColor
            )
            MetricCard(
                title: "Stale Caches",
                value: summary.staleCacheCount > 0 ? "\(summary.staleCacheCount)" : "None",
                icon: "clock.badge.exclamationmark",
                tint: summary.staleCacheCount > 0 ? .statusWarning : .statusHealthy
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

    private var sizeColor: Color {
        let T = GradleCacheThresholds.self
        if summary.totalCacheSize >= T.totalSizeCritical { return .statusError }
        if summary.totalCacheSize >= T.totalSizeWarning  { return .statusWarning }
        return .statusHealthy
    }
}
