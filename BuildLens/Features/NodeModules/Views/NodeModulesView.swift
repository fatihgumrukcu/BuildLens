import SwiftUI

struct NodeModulesView: View {
    @State private var viewModel = NodeModulesViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                NodeModulesLoadingView()

            case .loaded(let projects, let summary):
                if projects.isEmpty {
                    NodeModulesEmptyView(onRescan: { Task { await viewModel.rescan() } })
                } else {
                    NodeModulesDashboardView(viewModel: viewModel, summary: summary)
                }

            case .error(let message):
                NodeModulesErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.rescan() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
