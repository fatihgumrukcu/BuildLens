import SwiftUI

struct DiagnosticCategorySection: View {
    let title: String
    let severity: EnvironmentSeverity
    let issues: [DiagnosticIssue]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: severity.systemImage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(severityColor)
                Text(title)
                    .font(.appTitle3)
                    .foregroundStyle(Color.textPrimary)
                Text("\(issues.count)")
                    .font(.appCaption)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, AppSpacing.xxs + 2)
                    .padding(.vertical, 2)
                    .background(Color.appSurface, in: Capsule())
                Spacer()
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(issues) { issue in
                    DiagnosticIssueRow(issue: issue)
                    if issue.id != issues.last?.id {
                        Divider().padding(.leading, AppSpacing.xl)
                    }
                }
            }
            .cardStyle()
        }
    }

    private var severityColor: Color {
        switch severity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
