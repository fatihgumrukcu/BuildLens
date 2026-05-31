import SwiftUI

struct MetroCacheLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Scanning Metro cache\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Checking ~/Library/Caches/Metro, /tmp, and system temporary directories")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
