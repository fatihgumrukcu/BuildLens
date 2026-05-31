import SwiftUI

struct ArchivesView: View {
    @State private var viewModel = ArchivesViewModel()

    var body: some View {
        Group {
            switch viewModel.scanState {
            case .idle, .scanning:
                ArchivesLoadingView()

            case .loaded(let items, let summary):
                if items.isEmpty {
                    ArchivesEmptyView(onRescan: { Task { await viewModel.rescan() } })
                } else {
                    ArchivesDashboardView(viewModel: viewModel, summary: summary)
                }

            case .error(let message):
                ArchivesErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.rescan() } }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
