import SwiftUI

struct EnvironmentIssueRow: View {
    let issue: EnvironmentIssue

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            // Severity indicator
            Image(systemName: issue.severity.systemImage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(severityColor)
                .frame(width: 20, alignment: .top)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(issue.title)
                        .font(.appBody)
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    if let storage = issue.affectedStorage, storage > 0 {
                        Text(storage.formattedBytes)
                            .font(.appFootnote.monospacedDigit())
                            .foregroundStyle(Color.textTertiary)
                    }
                }

                Text(issue.description)
                    .font(.appCallout)
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 11))
                    Text(issue.recommendation)
                        .font(.appFootnote)
                }
                .foregroundStyle(Color.accentColor.opacity(0.8))
                .padding(.top, 2)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var severityColor: Color {
        switch issue.severity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
