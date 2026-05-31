import SwiftUI

struct EnvironmentHealthLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Analysing environment\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Scanning DerivedData, Simulators, Caches, and Archives")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
