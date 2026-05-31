import SwiftUI

struct DiagnosticIssueRow: View {
    let issue: DiagnosticIssue

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: issue.severity.systemImage)
                .font(.system(size: 13))
                .foregroundStyle(severityColor)
                .frame(width: 18, alignment: .top)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(issue.title)
                        .font(.appBody)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    sourceBadge
                    if let storage = issue.affectedStorage, storage > 0 {
                        Text(storage.formattedBytes)
                            .font(.appFootnote.monospacedDigit())
                            .foregroundStyle(Color.textTertiary)
                    }
                }

                if issue.severity != .healthy && !issue.recommendation.isEmpty {
                    Text(issue.recommendation)
                        .font(.appFootnote)
                        .foregroundStyle(Color.accentColor.opacity(0.8))
                }
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
    }

    private var sourceBadge: some View {
        Text(issue.source)
            .font(.appCaption)
            .padding(.horizontal, AppSpacing.xxs + 2)
            .padding(.vertical, 2)
            .background(Color.appSurface, in: Capsule())
            .foregroundStyle(Color.textTertiary)
    }

    private var severityColor: Color {
        switch issue.severity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
