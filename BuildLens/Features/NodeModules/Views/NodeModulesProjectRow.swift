import SwiftUI

struct NodeModulesProjectRow: View {
    let project: NodeModulesProject
    let maxSize: Int64

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Type icon
            Image(systemName: project.projectType.systemImage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(typeColor)
                .frame(width: 18)

            // Name + path
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xxs) {
                    Text(project.projectName)
                        .font(.appHeadline)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    badges
                }

                Text(project.projectPath.path.abbreviatedPath)
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            // Package count
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(project.packageCount)")
                    .font(.appFootnote.monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
                Text("pkgs")
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }
            .frame(width: 44)

            // Storage bar + size
            VStack(alignment: .trailing, spacing: 4) {
                Text(project.nodeModulesSize.formattedBytes)
                    .font(.appFootnote.monospacedDigit())
                    .foregroundStyle(sizeColor)

                GeometryReader { geo in
                    let fillW = maxSize > 0
                        ? geo.size.width * CGFloat(project.nodeModulesSize) / CGFloat(maxSize)
                        : 0
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.appBorder.opacity(0.25)).frame(height: 4)
                        Capsule().fill(sizeColor.opacity(0.7)).frame(width: fillW, height: 4)
                    }
                }
                .frame(width: 100, height: 4)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var badges: some View {
        HStack(spacing: AppSpacing.xxs) {
            if project.isAbandoned {
                badge("abandoned", color: .statusError)
            } else if project.isStale {
                badge("stale", color: .statusWarning)
            }
            if project.isOversized {
                badge("large", color: .statusWarning)
            }
        }
    }

    private func badge(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.appCaption)
            .padding(.horizontal, AppSpacing.xxs + 2)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
            .foregroundStyle(color)
    }

    private var typeColor: Color {
        switch project.projectType {
        case .reactNative: return .blue
        case .expo:        return .purple
        case .nextjs:      return Color.textPrimary
        case .node:        return .green
        }
    }

    private var sizeColor: Color {
        switch project.healthSeverity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
