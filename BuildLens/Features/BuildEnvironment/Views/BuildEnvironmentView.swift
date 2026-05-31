import SwiftUI

struct BuildEnvironmentView: View {
    @State private var viewModel = BuildEnvironmentViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                EnvironmentLoadingView()

            case .loaded(let summary):
                EnvironmentDashboardView(viewModel: viewModel, summary: summary)

            case .error(let message):
                EnvironmentErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.rescan() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
