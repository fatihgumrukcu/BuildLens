import SwiftUI

struct WorkspaceDashboardView: View {
    @Bindable var viewModel: WorkspaceViewModel
    let summary: WorkspaceSummary

    @State private var selectedProject: WorkspaceProject? = nil

    var body: some View {
        VStack(spacing: 0) {
            WorkspaceSummaryHeader(
                summary: summary,
                isRescanning: viewModel.isRescanning,
                onRescan: { Task { await viewModel.rescan() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {

                    // Filter bar
                    HStack(spacing: AppSpacing.sm) {
                        WorkspaceSearchBar(query: $viewModel.searchQuery)
                            .frame(maxWidth: 280)

                        Picker("Type", selection: $viewModel.selectedTypeFilter) {
                            Text("All Types").tag(WorkspaceProjectType?.none)
                            ForEach(WorkspaceProjectType.allCases.filter { $0 != .unknown }, id: \.self) { t in
                                Label(t.rawValue, systemImage: t.systemImage).tag(WorkspaceProjectType?.some(t))
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)

                        Toggle("Issues Only", isOn: $viewModel.showOnlyWithIssues)
                            .toggleStyle(.button)
                            .controlSize(.small)

                        Toggle("Stale Only", isOn: $viewModel.showOnlyStale)
                            .toggleStyle(.button)
                            .controlSize(.small)

                        Spacer()

                        Picker("Sort by", selection: $viewModel.sortOrder) {
                            ForEach(WorkspaceSortOrder.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 180)
                    }

                    // Storage distribution map — always shows unfiltered data
                    WorkspaceStorageMapView(projects: viewModel.projects)

                    // Project grid — reflects active filters
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            SectionHeader(
                                title: "Projects",
                                badge: "\(viewModel.filteredProjects.count) of \(viewModel.projects.count)"
                            )
                        }
                        WorkspaceProjectGrid(
                            projects: viewModel.filteredProjects,
                            onSelect: { selectedProject = $0 }
                        )
                    }
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
        .sheet(item: $selectedProject) { project in
            WorkspaceProjectDetailView(project: project)
        }
    }
}
