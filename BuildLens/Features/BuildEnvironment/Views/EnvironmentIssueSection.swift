import SwiftUI

struct EnvironmentIssueSection: View {
    let issues: [BuildToolIssue]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Issues", badge: "\(issues.count)")

            VStack(alignment: .leading, spacing: 0) {
                ForEach(issues) { issue in
                    issueRow(issue)
                    if issue.id != issues.last?.id {
                        Divider().padding(.leading, AppSpacing.xl)
                    }
                }
            }
            .cardStyle()
        }
    }

    private func issueRow(_ issue: BuildToolIssue) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: issue.severity.systemImage)
                .font(.system(size: 13))
                .foregroundStyle(severityColor(issue.severity))
                .frame(width: 18, alignment: .top)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(issue.title)
                    .font(.appBody)
                    .foregroundStyle(Color.textPrimary)
                Text(issue.recommendation)
                    .font(.appFootnote)
                    .foregroundStyle(Color.accentColor.opacity(0.8))
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
    }

    private func severityColor(_ s: EnvironmentSeverity) -> Color {
        switch s {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
