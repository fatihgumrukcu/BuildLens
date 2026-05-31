import SwiftUI

struct NodeModulesLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Scanning node_modules\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Discovering JavaScript and React Native projects across your developer folders")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
