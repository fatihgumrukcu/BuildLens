import SwiftUI

struct SimulatorEmptyView: View {
    let onRescan: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "iphone.slash")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(Color.textTertiary)

            Text("No simulators found")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text("Open Xcode and download at least one simulator runtime\nto get started.")
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
