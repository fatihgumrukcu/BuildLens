import SwiftUI

struct DiagnosticsLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Running full diagnostics\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Scanning Xcode, Node Modules, Metro Cache, Gradle, Archives, and Build Environment simultaneously")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
