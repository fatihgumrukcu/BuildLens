import SwiftUI

struct EnvironmentToolListView: View {
    let toolsByCategory: [(category: BuildToolCategory, tools: [BuildTool])]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            ForEach(toolsByCategory, id: \.category) { group in
                categorySection(group.category, tools: group.tools)
            }
        }
    }

    private func categorySection(_ category: BuildToolCategory, tools: [BuildTool]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
                Text(category.rawValue)
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                let installed = tools.filter(\.isInstalled).count
                Text("\(installed)/\(tools.count)")
                    .font(.appCaption.monospacedDigit())
                    .foregroundStyle(installed == tools.count ? Color.statusHealthy : Color.statusWarning)
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(tools) { tool in
                    EnvironmentToolRowView(tool: tool)
                    if tool.id != tools.last?.id {
                        Divider().padding(.leading, AppSpacing.xs + 10)
                    }
                }
            }
            .cardStyle()
        }
    }
}
