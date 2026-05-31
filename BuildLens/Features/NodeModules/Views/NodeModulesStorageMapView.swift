import SwiftUI

struct NodeModulesStorageMapView: View {
    let projects: [NodeModulesProject]

    private var top: [NodeModulesProject] {
        Array(projects.sorted { $0.nodeModulesSize > $1.nodeModulesSize }.prefix(8))
    }
    private var maxSize: Int64 { top.first?.nodeModulesSize ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Storage Distribution")
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                HStack(spacing: AppSpacing.sm) {
                    legendDot(.blue,   "React Native")
                    legendDot(.purple, "Expo")
                    legendDot(.green,  "Node / Next.js")
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

    private func storageRow(_ project: NodeModulesProject) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(project.projectName)
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
                .frame(width: 130, alignment: .leading)
                .lineLimit(1)

            GeometryReader { geo in
                let w     = geo.size.width
                let fillW = maxSize > 0
                    ? w * CGFloat(project.nodeModulesSize) / CGFloat(maxSize)
                    : 0
                HStack(spacing: 0) {
                    if fillW > 1 {
                        Rectangle()
                            .fill(typeBarColor(project.projectType).opacity(0.65))
                            .frame(width: fillW)
                    }
                    if w - fillW > 1 {
                        Rectangle()
                            .fill(Color.appBorder.opacity(0.15))
                            .frame(width: w - fillW)
                    }
                }
                .clipShape(Capsule())
                .frame(height: 6)
            }
            .frame(height: 6)

            Text(project.nodeModulesSize.formattedBytes)
                .font(.appCaption.monospacedDigit())
                .foregroundStyle(Color.textTertiary)
                .frame(width: 64, alignment: .trailing)
        }
    }

    private func typeBarColor(_ type: NodeModulesProjectType) -> Color {
        switch type {
        case .reactNative: return .blue
        case .expo:        return .purple
        case .nextjs, .node: return .green
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.appCaption).foregroundStyle(Color.textTertiary)
        }
    }
}
