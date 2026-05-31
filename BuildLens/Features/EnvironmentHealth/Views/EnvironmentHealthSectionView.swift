import SwiftUI

struct EnvironmentHealthSectionView: View {
    let section: EnvironmentHealthSection

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Header row
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: section.category.systemImage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(scoreColor)
                    .frame(width: 18)

                Text(section.category.rawValue)
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                // Score chip
                Text("\(section.score)")
                    .font(.appFootnote.monospacedDigit())
                    .padding(.horizontal, AppSpacing.xs - 1)
                    .padding(.vertical, 2)
                    .background(scoreColor.opacity(0.12), in: Capsule())
                    .foregroundStyle(scoreColor)
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBorder.opacity(0.3)).frame(height: 4)
                    Capsule().fill(scoreColor.opacity(0.6))
                        .frame(width: geo.size.width * CGFloat(section.score) / 100, height: 4)
                }
            }
            .frame(height: 4)

            // Summary line
            Text(section.summary)
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(2)

            // Issue badges (up to 2)
            if !section.issues.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    ForEach(section.issues.prefix(2)) { issue in
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: issue.severity.systemImage)
                                .font(.system(size: 10))
                                .foregroundStyle(issueSeverityColor(issue.severity))
                            Text(issue.title)
                                .font(.appCaption)
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    if section.issues.count > 2 {
                        Text("+\(section.issues.count - 2) more")
                            .font(.appCaption)
                            .foregroundStyle(Color.textTertiary)
                    }
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                .strokeBorder(
                    section.hasIssues ? scoreColor.opacity(0.3) : Color.appBorder.opacity(0.4),
                    lineWidth: 0.5
                )
        )
    }

    private var scoreColor: Color {
        switch section.severity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }

    private func issueSeverityColor(_ severity: EnvironmentSeverity) -> Color {
        switch severity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
