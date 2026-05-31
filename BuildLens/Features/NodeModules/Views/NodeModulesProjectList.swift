import SwiftUI

struct NodeModulesProjectList: View {
    let projects: [NodeModulesProject]
    let totalProjects: Int

    private var maxSize: Int64 {
        projects.first?.nodeModulesSize ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(
                title: "Projects",
                badge: "\(projects.count) of \(totalProjects)"
            )

            if projects.isEmpty {
                emptyFilter
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(projects) { project in
                        NodeModulesProjectRow(project: project, maxSize: maxSize)
                        if project.id != projects.last?.id {
                            Divider().padding(.leading, AppSpacing.xl + AppSpacing.xs)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }

    private var emptyFilter: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundStyle(Color.textTertiary)
            Text("No projects match the active filters.")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
