import SwiftUI

struct WorkspaceSummaryHeader: View {
    let summary: WorkspaceSummary
    let isRescanning: Bool
    let onRescan: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MetricCard(
                title: "Projects",
                value: "\(summary.totalProjects)",
                icon: "folder",
                tint: .accentColor
            )
            MetricCard(
                title: "Total Storage",
                value: summary.totalWorkspaceStorage.formattedBytes,
                icon: "internaldrive",
                tint: Color.textSecondary
            )
            MetricCard(
                title: "Reclaimable",
                value: summary.reclaimableStorage > 0 ? summary.reclaimableStorage.formattedBytes : "—",
                icon: "arrow.down.circle",
                tint: summary.reclaimableStorage > 0 ? .statusWarning : .statusHealthy
            )
            MetricCard(
                title: "Stale Projects",
                value: summary.staleProjects > 0 ? "\(summary.staleProjects)" : "None",
                icon: "clock.badge.exclamationmark",
                tint: summary.staleProjects > 0 ? .statusWarning : .statusHealthy
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
