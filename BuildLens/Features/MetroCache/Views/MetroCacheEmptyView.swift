import SwiftUI

struct MetroCacheEmptyView: View {
    let onRescan: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "bolt.circle")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(Color.textTertiary)

            Text("No Metro cache found")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text("Metro hasn't created a cache yet, or it has already been cleared.")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            Text("Metro cache is created automatically when you run `npx react-native start` or start an Expo development server.")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)

            Button("Rescan", action: onRescan)
                .buttonStyle(.bordered)
                .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
