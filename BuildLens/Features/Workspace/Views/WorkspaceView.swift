import SwiftUI

struct WorkspaceView: View {
    @State private var viewModel = WorkspaceViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                WorkspaceLoadingView()

            case .loaded(let projects, let summary):
                if projects.isEmpty {
                    WorkspaceEmptyView(onRescan: { Task { await viewModel.rescan() } })
                } else {
                    WorkspaceDashboardView(viewModel: viewModel, summary: summary)
                }

            case .error(let message):
                WorkspaceErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.rescan() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
