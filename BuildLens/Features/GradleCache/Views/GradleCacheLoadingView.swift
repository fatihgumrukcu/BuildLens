import SwiftUI

struct GradleCacheLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Scanning Gradle cache\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Analyzing ~/.gradle — caches, wrapper distributions, daemon logs, and JDK toolchains")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
