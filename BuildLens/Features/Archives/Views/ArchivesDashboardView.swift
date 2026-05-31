import SwiftUI

struct ArchivesDashboardView: View {
    @Bindable var viewModel: ArchivesViewModel
    let summary: ArchiveSummary

    var body: some View {
        VStack(spacing: 0) {
            ArchivesSummaryHeader(
                summary: summary,
                onRescan: { Task { await viewModel.rescan() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    filterBar

                    ArchiveStorageBreakdownView(projects: summary.projects)

                    if !summary.issues.isEmpty {
                        ArchiveIssueSection(issues: summary.issues)
                    }

                    ArchiveProjectListView(
                        projects: viewModel.filteredProjects,
                        totalProjects: summary.projects.count
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
            searchField
            Toggle("Stale Only", isOn: $viewModel.showOnlyStale)
                .toggleStyle(.button)
                .controlSize(.small)
            Spacer()
            Picker("Sort", selection: $viewModel.sortOrder) {
                ForEach(ArchivesSortOrder.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
        }
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textTertiary)
            TextField("Search projects", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .font(.appBody)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs - 2)
        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: 240)
    }

    private var cleanupNote: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.textTertiary)
                .font(.system(size: 13))
            Text("Archives can be deleted in **Xcode Organizer** (Window → Organizer → Archives) or from the **Clean Up** tab.")
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: AppSpacing.xs))
    }
}
