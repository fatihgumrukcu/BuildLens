import SwiftUI

struct ArchiveProjectListView: View {
    let projects: [ArchiveProject]
    let totalProjects: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(
                title: "Projects",
                badge: projects.count == totalProjects
                    ? "\(totalProjects)"
                    : "\(projects.count) of \(totalProjects)"
            )

            if projects.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(Color.textTertiary)
                    Text("No projects match the active filter.")
                        .font(.appCallout)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(projects) { project in
                        ArchiveProjectSection(project: project)
                    }
                }
            }
        }
    }
}
