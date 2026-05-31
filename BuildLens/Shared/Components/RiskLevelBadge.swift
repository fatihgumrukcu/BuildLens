import SwiftUI

struct RiskLevelBadge: View {
    let level: CleanupRiskLevel

    var body: some View {
        Text(level.label)
            .font(.appCaption)
            .padding(.horizontal, AppSpacing.xs - 2)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.12), in: Capsule())
            .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        switch level {
        case .safe:     return .statusHealthy
        case .moderate: return .statusWarning
        case .caution:  return .statusError
        }
    }
}
