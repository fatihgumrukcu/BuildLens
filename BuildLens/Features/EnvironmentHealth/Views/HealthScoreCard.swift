import SwiftUI

struct HealthScoreCard: View {
    let report: EnvironmentHealthReport
    let isRescanning: Bool
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.xl) {
            // Score column
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("\(report.overallScore)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)
                    .monospacedDigit()

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: report.status.systemImage)
                        .font(.system(size: 11, weight: .semibold))
                    Text(report.status.label)
                        .font(.appFootnote)
                }
                .foregroundStyle(scoreColor)
            }

            Rectangle()
                .fill(Color.appBorder)
                .frame(width: 1, height: 56)

            // Metrics column
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                metricRow(icon: "exclamationmark.triangle",
                          label: report.issueCount == 0 ? "No issues found" : "\(report.issueCount) issue\(report.issueCount == 1 ? "" : "s") detected",
                          tint: report.issueCount == 0 ? .statusHealthy : scoreColor)

                metricRow(icon: "arrow.down.circle",
                          label: report.reclaimableStorage > 0 ? "\(report.reclaimableStorage.formattedBytes) reclaimable" : "Nothing to reclaim",
                          tint: report.reclaimableStorage > 0 ? .statusWarning : .statusHealthy)

                metricRow(icon: "clock",
                          label: "Scanned \(report.generatedAt.relativeDescription)",
                          tint: .textTertiary)
            }

            Spacer()

            Button(action: onRefresh) {
                if isRescanning {
                    ProgressView().controlSize(.small)
                } else {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isRescanning)
        }
        .padding(AppSpacing.contentPadding)
        .background(Color.appBackground)
    }

    private var scoreColor: Color {
        switch report.status {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }

    private func metricRow(icon: String, label: String, tint: Color) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(tint)
                .frame(width: 16)
            Text(label)
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
        }
    }
}

private extension Date {
    var relativeDescription: String {
        let seconds = Int(-timeIntervalSinceNow)
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(seconds / 60) min ago" }
        return "\(seconds / 3600) hr ago"
    }
}
