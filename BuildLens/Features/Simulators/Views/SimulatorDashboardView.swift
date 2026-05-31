import SwiftUI

// Shown when scan completes with data.
// Owns the header, summary cards, and the device list.
// @Bindable is required because .searchable needs a $viewModel.searchQuery binding.
struct SimulatorDashboardView: View {
    @Bindable var viewModel: SimulatorViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(AppSpacing.contentPadding)

            Divider()

            SimulatorListView(runtimes: viewModel.filteredRuntimes)
        }
        // macOS toolbar search field — integrates with the unified toolbar area
        .searchable(text: $viewModel.searchQuery, placement: .automatic, prompt: "Filter simulators")
        .background(Color.appBackground)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Simulators")
                        .font(.appLargeTitle)
                        .foregroundStyle(Color.textPrimary)
                    Text("iOS · iPadOS · tvOS · watchOS · visionOS")
                        .font(.appCallout)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Button {
                    Task { await viewModel.rescan() }
                } label: {
                    if viewModel.isRescanning {
                        ProgressView().controlSize(.small)
                    } else {
                        Label("Rescan", systemImage: "arrow.clockwise")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isRescanning)
            }

            SimulatorSummaryCards(summary: viewModel.summary)
        }
    }
}
