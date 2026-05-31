import SwiftUI

struct GradleCacheView: View {
    @State private var viewModel = GradleCacheViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                GradleCacheLoadingView()

            case .loaded(let entries, let summary):
                if entries.isEmpty {
                    GradleCacheEmptyView(onRescan: { Task { await viewModel.rescan() } })
                } else {
                    GradleCacheDashboardView(viewModel: viewModel, summary: summary)
                }

            case .error(let message):
                GradleCacheErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.rescan() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
