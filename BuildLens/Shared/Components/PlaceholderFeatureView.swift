import SwiftUI

// Shown for destinations not yet built. Remove a case from DetailRouterView
// and add the real view when a feature graduates from Phase 1.
struct PlaceholderFeatureView: View {
    let destination: AppDestination

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: destination.systemImage)
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(Color.accentColor.opacity(0.7))

            Text(destination.title)
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text("Coming soon")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
