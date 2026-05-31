import SwiftUI

struct DashboardEnvironmentSection: View {
    let tools: [EnvironmentTool]
    let isLoaded: Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.xs), count: 2)

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Environment", badge: healthBadge)

            if !isLoaded {
                ScanningPlaceholderView()
            } else {
                LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
                    ForEach(tools) { tool in
                        ToolRowView(tool: tool)
                    }
                }
            }
        }
    }

    private var healthBadge: String? {
        guard isLoaded, !tools.isEmpty else { return nil }
        let installed = tools.filter { $0.status == .installed }.count
        return "\(installed)/\(tools.count) installed"
    }
}

// MARK: - Subviews

private struct ToolRowView: View {
    let tool: EnvironmentTool

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            StatusBadge(status: tool.status)

            VStack(alignment: .leading, spacing: 2) {
                Text(tool.name)
                    .font(.appFootnote)
                    .foregroundStyle(Color.textPrimary)
                Group {
                    if let version = tool.version {
                        Text(version)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } else {
                        Text("Not found")
                    }
                }
                .font(.appMonoSmall)
                .foregroundStyle(Color.textSecondary)
            }
            Spacer()
        }
        .cardStyle()
    }
}

private struct ScanningPlaceholderView: View {
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ProgressView()
                .controlSize(.small)
            Text("Scanning environment…")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .cardStyle()
    }
}
