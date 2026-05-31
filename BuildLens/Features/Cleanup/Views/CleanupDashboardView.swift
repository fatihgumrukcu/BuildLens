import SwiftUI

struct CleanupDashboardView: View {
    let viewModel: CleanupViewModel
    let preview: CleanupPreview

    var body: some View {
        VStack(spacing: 0) {
            CleanupSummaryHeader(
                preview: preview,
                onRescan: { Task { await viewModel.rescan() } },
                onClean: { viewModel.requestConfirmation() }
            )

            Divider()

            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(preview.itemsByCategory, id: \.category) { group in
                        CleanupCategorySection(
                            category: group.category,
                            items: group.items,
                            onToggle: { id in viewModel.toggleItem(id: id) },
                            onSelectAll: { viewModel.selectAll(in: group.category) },
                            onDeselectAll: { viewModel.deselectAll(in: group.category) }
                        )
                    }
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }
}
