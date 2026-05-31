import SwiftUI

struct EnvironmentLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Probing build environment\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Running version checks for Xcode, Node, Ruby, Java, Gradle, Homebrew, and more")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
