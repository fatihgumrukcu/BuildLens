import SwiftUI

struct MetroCacheDashboardView: View {
    @Bindable var viewModel: MetroCacheViewModel
    let summary: MetroCacheSummary

    var body: some View {
        VStack(spacing: 0) {
            MetroCacheSummaryHeader(
                summary: summary,
                entryCount: viewModel.totalEntries,
                isRescanning: viewModel.isRescanning,
                onRescan: { Task { await viewModel.rescan() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    filterBar

                    if !summary.issues.isEmpty {
                        MetroCacheIssueSection(issues: summary.issues)
                    }

                    MetroCacheListView(
                        entries: viewModel.filteredEntries,
                        totalEntries: viewModel.totalEntries
                    )

                    cleanupNote
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }

    private var filterBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Toggle("Stale Only", isOn: $viewModel.showOnlyStale)
                .toggleStyle(.button)
                .controlSize(.small)

            Spacer()

            Picker("Sort", selection: $viewModel.sortOrder) {
                ForEach(MetroCacheSortOrder.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)
        }
    }

    // Points users to the existing Cleanup Engine for deletion.
    private var cleanupNote: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.textTertiary)
                .font(.system(size: 13))
            Text("Metro cache can be cleared from the **Clean Up** tab. Metro rebuilds it automatically on next `npx react-native start`.")
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: AppSpacing.xs))
    }
}
