import SwiftUI

struct EnvironmentSummaryHeader: View {
    let summary: BuildEnvironmentSummary
    let isRescanning: Bool
    let onRescan: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MetricCard(
                title: "Total Tools",
                value: "\(summary.tools.count)",
                icon: "wrench.and.screwdriver",
                tint: .accentColor
            )
            MetricCard(
                title: "Installed",
                value: "\(summary.installedCount)",
                icon: "checkmark.circle",
                tint: .statusHealthy
            )
            MetricCard(
                title: "Missing",
                value: summary.missingCount > 0 ? "\(summary.missingCount)" : "None",
                icon: "xmark.circle",
                tint: summary.missingCount > 0 ? .statusError : .statusHealthy
            )
            MetricCard(
                title: "Health Score",
                value: "\(summary.healthScore)",
                icon: "heart.text.clipboard",
                tint: healthColor
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

    private var healthColor: Color {
        switch summary.healthSeverity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
