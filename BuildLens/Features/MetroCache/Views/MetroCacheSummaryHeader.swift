import SwiftUI

struct MetroCacheSummaryHeader: View {
    let summary: MetroCacheSummary
    let entryCount: Int
    let onRescan: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MetricCard(
                title: "Total Size",
                value: summary.totalCacheSize > 0
                    ? summary.totalCacheSize.formattedBytes
                    : "Empty",
                icon: "bolt.circle",
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
                value: summary.staleCaches > 0 ? "\(summary.staleCaches)" : "None",
                icon: "clock.badge.exclamationmark",
                tint: summary.staleCaches > 0 ? .statusWarning : .statusHealthy
            )
            MetricCard(
                title: "Oldest Entry",
                value: oldestLabel,
                icon: "calendar.badge.clock",
                tint: summary.staleCaches > 0 ? .statusWarning : Color.textSecondary
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
        let T = MetroCacheThresholds.self
        if summary.totalCacheSize >= T.totalSizeCritical { return .statusError }
        if summary.totalCacheSize >= T.totalSizeWarning  { return .statusWarning }
        return .statusHealthy
    }

    private var oldestLabel: String {
        guard let date = summary.oldestCacheDate else { return "—" }
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return days == 0 ? "Today" : "\(days)d ago"
    }
}
