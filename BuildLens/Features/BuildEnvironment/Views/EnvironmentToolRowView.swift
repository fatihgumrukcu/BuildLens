import SwiftUI

struct EnvironmentToolRowView: View {
    let tool: BuildTool

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Status dot
            StatusBadge(status: tool.legacyStatus)

            // Name + version
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xxs) {
                    Text(tool.name)
                        .font(.appFootnote)
                        .foregroundStyle(Color.textPrimary)
                    if tool.status == .outdated {
                        Text("outdated")
                            .font(.appCaption)
                            .padding(.horizontal, AppSpacing.xxs + 2)
                            .padding(.vertical, 2)
                            .background(Color.statusWarning.opacity(0.12), in: Capsule())
                            .foregroundStyle(Color.statusWarning)
                    }
                }
                if let version = tool.version {
                    Text(version)
                        .font(.appMonoSmall)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else if tool.isMissing {
                    Text("not installed")
                        .font(.appMonoSmall)
                        .foregroundStyle(Color.statusError.opacity(0.8))
                }
            }

            Spacer()

            // Path
            if let path = tool.abbreviatedPath {
                Text(path)
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: 200, alignment: .trailing)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
