import SwiftUI

// Root screen for the DerivedData feature.
// Owns the ViewModel and switches on scan state — no rendering logic lives here.
// Sort state is a local @State because it is a pure presentation concern;
// the ViewModel provides unsorted raw data and the computed `sortedItems` feeds the Table.
struct DerivedDataView: View {
    @State private var viewModel = DerivedDataViewModel()
    @State private var sortOrder = [KeyPathComparator(\DerivedDataItem.size, order: .reverse)]

    // Recomputes whenever viewModel.items or sortOrder changes — O(n log n), negligible for <1000 rows.
    private var sortedItems: [DerivedDataItem] {
        viewModel.items.sorted(using: sortOrder)
    }

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                DerivedDataScanningView()
            case .loaded:
                loadedView
            case .empty:
                DerivedDataEmptyView { Task { await viewModel.rescan() } }
            case .error(let message):
                DerivedDataErrorView(message: message) { Task { await viewModel.rescan() } }
            }
        }
        .background(Color.appBackground)
        .task { await viewModel.scan() }
    }

    // MARK: - Loaded layout

    private var loadedView: some View {
        VStack(spacing: 0) {
            DerivedDataSummaryHeader(
                totalSize: viewModel.totalSize,
                itemCount: viewModel.items.count,
                onRescan: { Task { await viewModel.rescan() } }
            )
            .padding(AppSpacing.contentPadding)

            Divider()

            DerivedDataListView(
                items: sortedItems,
                totalSize: viewModel.totalSize,
                sortOrder: $sortOrder
            )
        }
    }
}
