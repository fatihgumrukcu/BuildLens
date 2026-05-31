import SwiftUI

struct ArchivesLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Scanning archives\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            Text("Reading ~/Library/Developer/Xcode/Archives — analyzing sizes, dates, and release metadata")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
