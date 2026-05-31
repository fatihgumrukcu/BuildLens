import SwiftUI

struct SimulatorErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(Color.statusError.opacity(0.7))

            Text("Simulator scan failed")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text(message)
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

            // xcrun simctl requires Xcode to be installed — give the user a direct hint
            Text("Make sure Xcode is installed and a command-line tools path is selected in Xcode → Settings → Locations.")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)

            Button("Try Again", action: onRetry)
                .buttonStyle(.bordered)
                .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
