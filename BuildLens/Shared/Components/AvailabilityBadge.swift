import SwiftUI

// Reusable "Available / Unavailable" pill badge.
// Used by simulators, runtimes, and future features that report tool/resource availability.
struct AvailabilityBadge: View {
    let isAvailable: Bool

    var body: some View {
        Text(isAvailable ? "Available" : "Unavailable")
            .font(.appCaption)
            .padding(.horizontal, AppSpacing.xs - 2)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.12), in: Capsule())
            .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        isAvailable ? .statusHealthy : .statusError
    }
}
