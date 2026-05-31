import SwiftUI

struct WorkspaceProjectGrid: View {
    let projects: [WorkspaceProject]
    let onSelect: (WorkspaceProject) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.sm),
        GridItem(.flexible(), spacing: AppSpacing.sm),
        GridItem(.flexible(), spacing: AppSpacing.sm),
    ]

    var body: some View {
        if projects.isEmpty {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 32, weight: .ultraLight))
                    .foregroundStyle(Color.textTertiary)
                Text("No projects match your filters")
                    .font(.appCallout)
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, AppSpacing.xxxl)
        } else {
            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(projects) { project in
                    WorkspaceProjectCard(
                        project: project,
                        onSelect: { onSelect(project) }
                    )
                }
            }
        }
    }
}
