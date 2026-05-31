import SwiftUI

struct EnvironmentHealthView: View {
    @State private var viewModel = EnvironmentHealthViewModel()

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                EnvironmentHealthLoadingView()

            case .loaded(let report):
                EnvironmentHealthDashboardView(viewModel: viewModel, report: report)

            case .error(let message):
                EnvironmentHealthErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.refresh() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.load() }
    }
}
