import SwiftUI

struct WorkspaceProjectCard: View {
    let project: WorkspaceProject
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Header row: icon + name + health chip
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: project.projectType.systemImage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(typeColor)
                        .frame(width: 18)

                    Text(project.name)
                        .font(.appHeadline)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // Health score chip
                    Text("\(project.healthScore)")
                        .font(.appCaption.monospacedDigit())
                        .padding(.horizontal, AppSpacing.xs - 2)
                        .padding(.vertical, 2)
                        .background(healthColor.opacity(0.12), in: Capsule())
                        .foregroundStyle(healthColor)
                }

                // Type + git badge row
                HStack(spacing: AppSpacing.xxs) {
                    Text(project.projectType.rawValue)
                        .font(.appCaption)
                        .padding(.horizontal, AppSpacing.xs - 2)
                        .padding(.vertical, 2)
                        .background(typeColor.opacity(0.1), in: Capsule())
                        .foregroundStyle(typeColor)

                    if project.isGitRepository {
                        Text("git")
                            .font(.appCaption)
                            .padding(.horizontal, AppSpacing.xs - 2)
                            .padding(.vertical, 2)
                            .background(Color.textTertiary.opacity(0.1), in: Capsule())
                            .foregroundStyle(Color.textTertiary)
                    }

                    if project.isStale {
                        Text("stale")
                            .font(.appCaption)
                            .padding(.horizontal, AppSpacing.xs - 2)
                            .padding(.vertical, 2)
                            .background(Color.statusWarning.opacity(0.1), in: Capsule())
                            .foregroundStyle(Color.statusWarning)
                    }
                }

                // Path
                Text(project.url.path.abbreviatedPath)
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)

                Divider()

                // Storage metrics row
                HStack(spacing: AppSpacing.md) {
                    storageChip(label: "Total", value: project.totalSize.formattedBytes, color: .textSecondary)
                    if project.reclaimableSize > 0 {
                        storageChip(label: "Reclaimable", value: project.reclaimableSize.formattedBytes, color: .statusWarning)
                    }
                }

                // Issues footer
                if project.issueCount > 0 {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(healthColor)
                        Text("\(project.issueCount) issue\(project.issueCount == 1 ? "" : "s")")
                            .font(.appCaption)
                            .foregroundStyle(healthColor)
                    }
                }
            }
            .padding(AppSpacing.cardPadding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                    .strokeBorder(project.issueCount > 0 ? healthColor.opacity(0.25) : Color.appBorder.opacity(0.4), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var healthColor: Color {
        switch project.healthSeverity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }

    private var typeColor: Color {
        switch project.projectType {
        case .reactNative, .expo: return .blue
        case .ios:                return Color(NSColor.secondaryLabelColor)
        case .android:            return .green
        case .node, .nextjs:      return .green
        case .flutter:            return .cyan
        case .swift:              return .orange
        case .unknown:            return Color(NSColor.tertiaryLabelColor)
        }
    }

    private func storageChip(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.appFootnote.monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.appCaption)
                .foregroundStyle(Color.textTertiary)
        }
    }
}
