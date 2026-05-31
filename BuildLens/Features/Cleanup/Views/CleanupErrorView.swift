import SwiftUI

struct CleanupErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(Color.statusError.opacity(0.7))

            Text("Scan failed")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text(message)
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

            Button("Try Again", action: onRetry)
                .buttonStyle(.bordered)
                .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
