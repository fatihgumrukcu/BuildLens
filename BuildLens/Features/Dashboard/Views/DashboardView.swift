import SwiftUI

// Root dashboard screen. Owns the ViewModel and delegates rendering
// to focused sub-views. Under 50 lines — layout only.
struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                DashboardHeaderView(isLoading: viewModel.isLoading, onReload: {
                    Task { await viewModel.reload() }
                })
                StorageOverviewSection(summary: viewModel.summary)
                DashboardEnvironmentSection(tools: viewModel.summary.environmentTools,
                                           isLoaded: viewModel.summary.isLoaded)
            }
            .contentPadding()
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .task { await viewModel.load() }
    }
}
