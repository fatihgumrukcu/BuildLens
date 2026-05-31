import SwiftUI

struct NodeModulesDashboardView: View {
    @Bindable var viewModel: NodeModulesViewModel
    let summary: NodeModulesSummary

    var body: some View {
        VStack(spacing: 0) {
            NodeModulesSummaryHeader(
                summary: summary,
                onRescan: { Task { await viewModel.rescan() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    filterBar

                    NodeModulesStorageMapView(projects: viewModel.projects)

                    if !summary.topIssues.isEmpty {
                        NodeModulesIssueSection(issues: summary.topIssues)
                    }

                    NodeModulesProjectList(
                        projects: viewModel.filteredProjects,
                        totalProjects: viewModel.projects.count
                    )
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }

    private var filterBar: some View {
        HStack(spacing: AppSpacing.sm) {
            filterSearchField

            Picker("Type", selection: $viewModel.selectedTypeFilter) {
                Text("All Types").tag(NodeModulesProjectType?.none)
                ForEach(NodeModulesProjectType.allCases, id: \.self) { t in
                    Label(t.rawValue, systemImage: t.systemImage)
                        .tag(NodeModulesProjectType?.some(t))
                }
            }
            .pickerStyle(.menu)
            .frame(width: 150)

            Toggle("Stale", isOn: $viewModel.showOnlyStale)
                .toggleStyle(.button)
                .controlSize(.small)

            Toggle("Oversized", isOn: $viewModel.showOnlyOversized)
                .toggleStyle(.button)
                .controlSize(.small)

            Spacer()

            Picker("Sort", selection: $viewModel.sortOrder) {
                ForEach(NodeModulesSortOrder.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
        }
    }

    private var filterSearchField: some View {
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
        .frame(maxWidth: 260)
    }
}
