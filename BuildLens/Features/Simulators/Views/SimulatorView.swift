import SwiftUI

// Root screen entry point. Owns the ViewModel, dispatches to state-specific views.
// Zero rendering logic — only state switching lives here.
struct SimulatorView: View {
    @State private var viewModel = SimulatorViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                SimulatorLoadingView()
            case .loaded:
                SimulatorDashboardView(viewModel: viewModel)
            case .empty:
                SimulatorEmptyView { Task { await viewModel.rescan() } }
            case .error(let message):
                SimulatorErrorView(message: message) { Task { await viewModel.rescan() } }
            }
        }
        .background(Color.appBackground)
        .task { await viewModel.scan() }
    }
}
