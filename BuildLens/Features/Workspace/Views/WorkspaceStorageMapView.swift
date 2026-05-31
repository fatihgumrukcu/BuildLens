import SwiftUI

struct WorkspaceStorageMapView: View {
    let projects: [WorkspaceProject]

    private var top: [WorkspaceProject] {
        Array(projects.sorted { $0.totalSize > $1.totalSize }.prefix(8))
    }

    private var maxSize: Int64 { top.first?.totalSize ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Storage Distribution")
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                // Legend
                HStack(spacing: AppSpacing.sm) {
                    legendDot(.orange, "node_modules")
                    legendDot(.blue.opacity(0.7), "Pods")
                    legendDot(Color.textTertiary.opacity(0.5), "Other")
                }
            }

            if top.isEmpty {
                Text("No project data available")
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
            } else {
                ForEach(top) { project in
                    storageRow(project)
                }
            }
        }
        .cardStyle()
    }

    private func storageRow(_ project: WorkspaceProject) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(project.name)
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
                .frame(width: 130, alignment: .leading)
                .lineLimit(1)

            GeometryReader { geo in
                let w    = geo.size.width
                let nmW  = barWidth(project.nodeModulesSize, total: w)
                let podsW = barWidth(project.podsSize, total: w)
                let otherSize = max(0, project.totalSize - project.nodeModulesSize - project.podsSize)
                let otherW = barWidth(otherSize, total: w)

                HStack(spacing: 1) {
                    if nmW > 1    { Rectangle().fill(Color.orange.opacity(0.65)).frame(width: nmW) }
                    if podsW > 1  { Rectangle().fill(Color.blue.opacity(0.5)).frame(width: podsW) }
                    if otherW > 1 { Rectangle().fill(Color.textTertiary.opacity(0.25)).frame(width: otherW) }
                }
                .clipShape(Capsule())
                .frame(height: 6)
            }
            .frame(height: 6)

            Text(project.totalSize.formattedBytes)
                .font(.appCaption.monospacedDigit())
                .foregroundStyle(Color.textTertiary)
                .frame(width: 58, alignment: .trailing)
        }
    }

    private func barWidth(_ size: Int64, total: CGFloat) -> CGFloat {
        guard maxSize > 0, size > 0 else { return 0 }
        return total * CGFloat(size) / CGFloat(maxSize)
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.appCaption).foregroundStyle(Color.textTertiary)
        }
    }
}
