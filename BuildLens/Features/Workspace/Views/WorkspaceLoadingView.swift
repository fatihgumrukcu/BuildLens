import SwiftUI

struct WorkspaceLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Discovering developer projects\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Scanning Desktop, Developer, Documents, and common project folders")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
