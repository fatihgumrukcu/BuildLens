import SwiftUI

struct EnvironmentIssueList: View {
    let issues: [EnvironmentIssue]
    @Binding var selectedFilter: EnvironmentSeverity?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Issues")
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                // Severity filter pills
                HStack(spacing: AppSpacing.xxs) {
                    filterPill(nil, label: "All")
                    filterPill(.critical, label: "Critical")
                    filterPill(.warning,  label: "Warning")
                }
            }

            if issues.isEmpty {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.statusHealthy)
                    Text("No issues detected")
                        .font(.appCallout)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.vertical, AppSpacing.sm)
            } else {
                VStack(spacing: 0) {
                    ForEach(issues) { issue in
                        EnvironmentIssueRow(issue: issue)
                        if issue.id != issues.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    private func filterPill(_ severity: EnvironmentSeverity?, label: String) -> some View {
        let isActive = selectedFilter == severity
        return Button {
            selectedFilter = isActive ? nil : severity
        } label: {
            Text(label)
                .font(.appCaption)
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, 3)
                .background(isActive ? Color.accentColor.opacity(0.15) : Color.clear, in: Capsule())
                .foregroundStyle(isActive ? Color.accentColor : Color.textSecondary)
                .overlay(Capsule().strokeBorder(isActive ? Color.accentColor.opacity(0.4) : Color.appBorder.opacity(0.6), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}
