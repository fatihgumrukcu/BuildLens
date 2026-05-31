import SwiftUI

struct MetroCacheView: View {
    @State private var viewModel = MetroCacheViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                MetroCacheLoadingView()

            case .loaded(let entries, let summary):
                if entries.isEmpty {
                    MetroCacheEmptyView(onRescan: { Task { await viewModel.rescan() } })
                } else {
                    MetroCacheDashboardView(viewModel: viewModel, summary: summary)
                }

            case .error(let message):
                MetroCacheErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.rescan() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
