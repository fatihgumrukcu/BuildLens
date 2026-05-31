import SwiftUI

struct WorkspaceIssueSection: View {
    let issues: [WorkspaceIssue]

    var body: some View {
        if issues.isEmpty {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.statusHealthy)
                Text("No issues detected")
                    .font(.appCallout)
                    .foregroundStyle(Color.textSecondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(issues) { issue in
                    issueRow(issue)
                    if issue.id != issues.last?.id {
                        Divider().padding(.leading, AppSpacing.xl)
                    }
                }
            }
        }
    }

    private func issueRow(_ issue: WorkspaceIssue) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: issue.severity.systemImage)
                .font(.system(size: 13))
                .foregroundStyle(severityColor(issue.severity))
                .frame(width: 18, alignment: .top)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack {
                    Text(issue.title)
                        .font(.appBody)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    if let s = issue.affectedStorage, s > 0 {
                        Text(s.formattedBytes)
                            .font(.appFootnote.monospacedDigit())
                            .foregroundStyle(Color.textTertiary)
                    }
                }
                Text(issue.recommendation)
                    .font(.appFootnote)
                    .foregroundStyle(Color.accentColor.opacity(0.8))
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private func severityColor(_ s: EnvironmentSeverity) -> Color {
        switch s {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
