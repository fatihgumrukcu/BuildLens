import SwiftUI

struct ArchivesEmptyView: View {
    let onRescan: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "archivebox")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(Color.textTertiary)

            Text("No archives found")
                .font(.appTitle2)
                .foregroundStyle(Color.textPrimary)

            Text("Xcode archives are created when you archive a project via Product → Archive.")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            Text("Archives are stored in ~/Library/Developer/Xcode/Archives/ and are used for App Store submissions, TestFlight builds, and AdHoc distribution.")
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
