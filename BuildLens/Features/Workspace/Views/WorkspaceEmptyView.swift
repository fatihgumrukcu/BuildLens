import SwiftUI

struct WorkspaceEmptyView: View {
    let onRescan: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(Color.textTertiary)

            Text("No projects found")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text("BuildLens scans ~/Desktop, ~/Developer, ~/Documents,\n~/Code, ~/Projects, ~/Workspace, ~/dev, and ~/repos.")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            Text("Projects are detected by the presence of package.json, Podfile, Package.swift, pubspec.yaml, .xcodeproj, or a .git directory.")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

            Button("Rescan", action: onRescan)
                .buttonStyle(.bordered)
                .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
