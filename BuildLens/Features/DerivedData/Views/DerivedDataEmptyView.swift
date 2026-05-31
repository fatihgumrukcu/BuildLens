import SwiftUI

struct DerivedDataEmptyView: View {
    let onRescan: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(Color.statusHealthy.opacity(0.7))

            Text("DerivedData is clean")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text("No build artifacts found in\n~/Library/Developer/Xcode/DerivedData")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            Button("Rescan", action: onRescan)
                .buttonStyle(.bordered)
                .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
