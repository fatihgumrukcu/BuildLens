import SwiftUI

// Health overview grid — one card per diagnostic category showing worst-case severity.
struct DiagnosticsTimelineView: View {
    let summary: DiagnosticSummary

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Category Health")
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 5),
                spacing: AppSpacing.sm
            ) {
                ForEach(DiagnosticCategory.allCases, id: \.self) { cat in
                    categoryCard(cat)
                }
            }
        }
        .cardStyle()
    }

    private func categoryCard(_ category: DiagnosticCategory) -> some View {
        let sev = summary.categoryHealth[category] ?? .healthy
        let issueCount = summary.allIssues.filter { $0.category == category }.count

        return VStack(spacing: AppSpacing.xxs + 2) {
            Image(systemName: category.systemImage)
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(severityColor(sev))

            Text(category.rawValue)
                .font(.appCaption)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if issueCount > 0 {
                Text("\(issueCount) issue\(issueCount == 1 ? "" : "s")")
                    .font(.appCaption)
                    .foregroundStyle(severityColor(sev))
            } else {
                Text("healthy")
                    .font(.appCaption)
                    .foregroundStyle(Color.statusHealthy)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xs)
        .background(severityColor(sev).opacity(0.06), in: RoundedRectangle(cornerRadius: AppSpacing.xs))
    }

    private func severityColor(_ s: EnvironmentSeverity) -> Color {
        switch s {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
