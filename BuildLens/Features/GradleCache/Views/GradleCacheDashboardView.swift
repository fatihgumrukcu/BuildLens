import SwiftUI

struct GradleCacheDashboardView: View {
    @Bindable var viewModel: GradleCacheViewModel
    let summary: GradleCacheSummary

    var body: some View {
        VStack(spacing: 0) {
            GradleCacheSummaryHeader(
                summary: summary,
                entryCount: viewModel.totalEntries,
                isRescanning: viewModel.isRescanning,
                onRescan: { Task { await viewModel.rescan() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    GradleCacheStorageView(summary: summary)

                    if !summary.issues.isEmpty {
                        GradleCacheIssueSection(issues: summary.issues)
                    }

                    categoryFilter

                    ForEach(viewModel.entriesByCategory, id: \.category) { group in
                        GradleCacheCategorySection(
                            category: group.category,
                            entries: group.entries
                        )
                    }

                    cleanupNote
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }

    private var categoryFilter: some View {
        HStack(spacing: AppSpacing.xs) {
            filterChip(nil, label: "All")
            ForEach(GradleCacheCategory.allCases, id: \.self) { cat in
                filterChip(cat, label: cat.rawValue)
            }
            Spacer()
        }
    }

    private func filterChip(_ category: GradleCacheCategory?, label: String) -> some View {
        let isSelected = viewModel.selectedCategory == category
        return Button {
            viewModel.selectedCategory = isSelected ? nil : category
        } label: {
            Text(label)
                .font(.appCaption)
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxs + 2)
                .background(
                    isSelected ? Color.accentColor.opacity(0.15) : Color.appSurface,
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? Color.accentColor : Color.textSecondary)
        }
        .buttonStyle(.plain)
    }

    private var cleanupNote: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.textTertiary)
                .font(.system(size: 13))
            Text("Gradle caches can be cleared from the **Clean Up** tab. Gradle re-downloads only what is needed on the next build.")
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: AppSpacing.xs))
    }
}
