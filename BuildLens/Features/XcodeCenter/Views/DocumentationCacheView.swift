import SwiftUI

struct DocumentationCacheView: View {
    let section: XcodeStorageSection

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Documentation Cache")

            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.purple)

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(section.size.formattedBytes)
                        .font(.appTitle3)
                        .foregroundStyle(Color.textPrimary)
                    Text("Cached developer documentation")
                        .font(.appFootnote)
                        .foregroundStyle(Color.textSecondary)
                    Text("Safe to delete — Xcode re-downloads documentation on demand.")
                        .font(.appCaption)
                        .foregroundStyle(Color.textTertiary)
                }

                Spacer()
            }
            .padding(AppSpacing.sm)
            .cardStyle()
        }
    }
}
