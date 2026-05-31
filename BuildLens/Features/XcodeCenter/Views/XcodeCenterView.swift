import SwiftUI

struct XcodeCenterView: View {
    @State private var viewModel = XcodeCenterViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                XcodeCenterLoadingView()

            case .loaded(let summary):
                XcodeCenterDashboardView(viewModel: viewModel, summary: summary)

            case .error(let message):
                XcodeCenterErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.reload() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.load() }
    }
}
