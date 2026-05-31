import SwiftUI

struct DiagnosticsView: View {
    @State private var viewModel = DiagnosticsViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                DiagnosticsLoadingView()

            case .loaded(let summary):
                DiagnosticsDashboardView(viewModel: viewModel, summary: summary)

            case .error(let message):
                DiagnosticsErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.rescan() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
