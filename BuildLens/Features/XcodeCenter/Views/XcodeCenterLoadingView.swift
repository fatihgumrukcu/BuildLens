import SwiftUI

struct XcodeCenterLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Loading Xcode Infrastructure\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Aggregating DerivedData, Archives, Simulators, Device Support, and Xcode version information")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
