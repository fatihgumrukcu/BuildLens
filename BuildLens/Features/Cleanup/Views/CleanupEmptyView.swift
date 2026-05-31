import SwiftUI

struct CleanupEmptyView: View {
    let onScan: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(Color.textTertiary)

            Text("Nothing to clean up")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text("No developer caches were found.\nBuild something first, then come back.")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            Button("Scan Again", action: onScan)
                .buttonStyle(.bordered)
                .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
