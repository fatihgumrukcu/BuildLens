import SwiftUI

struct XcodeInfrastructureHeader: View {
    let summary: XcodeInfrastructureSummary
    let onReload: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MetricCard(
                title: "Xcode Storage",
                value: summary.totalXcodeStorage > 0
                    ? summary.totalXcodeStorage.formattedBytes
                    : "—",
                icon: "hammer",
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
                title: "Archives",
                value: summary.archiveCount > 0 ? "\(summary.archiveCount)" : "None",
                icon: "archivebox",
                tint: summary.staleArchiveCount > 0 ? .statusWarning : Color.textSecondary
            )
            MetricCard(
                title: "DerivedData",
                value: summary.derivedDataCount > 0 ? "\(summary.derivedDataCount) items" : "Empty",
                icon: "hammer",
                tint: .accentColor
            )

            Spacer()

            if let version = summary.activeXcodeVersion {
                Text(version)
                    .font(.appFootnote)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxs + 2)
                    .background(Color.appSurface, in: Capsule())
            }

            Button(action: onReload) {
                Label("Reload", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding(AppSpacing.contentPadding)
        .background(Color.appBackground)
    }

    private var sizeColor: Color {
        if summary.totalXcodeStorage >= 60 * 1_073_741_824 { return .statusError }
        if summary.totalXcodeStorage >= 20 * 1_073_741_824 { return .statusWarning }
        return .statusHealthy
    }
}
