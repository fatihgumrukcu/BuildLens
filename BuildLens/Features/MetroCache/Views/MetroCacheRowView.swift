import SwiftUI

struct MetroCacheRowView: View {
    let entry: MetroCacheEntry
    let maxSize: Int64

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Source icon
            Image(systemName: entry.source.systemImage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(sourceColor)
                .frame(width: 18)

            // Name + path
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xxs) {
                    Text(entry.displayName)
                        .font(.appHeadline)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    badges
                }
                Text(entry.path.path.abbreviatedPath)
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            // Age
            VStack(alignment: .trailing, spacing: 2) {
                Text(ageLabel)
                    .font(.appFootnote.monospacedDigit())
                    .foregroundStyle(entry.isStale ? Color.statusWarning : Color.textSecondary)
                Text("old")
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }
            .frame(width: 52)

            // Size + bar
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.size.formattedBytes)
                    .font(.appFootnote.monospacedDigit())
                    .foregroundStyle(severityColor)

                GeometryReader { geo in
                    let fillW = maxSize > 0
                        ? geo.size.width * CGFloat(entry.size) / CGFloat(maxSize)
                        : 0
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.appBorder.opacity(0.25)).frame(height: 4)
                        Capsule().fill(severityColor.opacity(0.7)).frame(width: fillW, height: 4)
                    }
                }
                .frame(width: 100, height: 4)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var badges: some View {
        HStack(spacing: AppSpacing.xxs) {
            if entry.source == .tmpArtifact {
                chip(entry.source.rawValue, color: Color.textSecondary)
            }
            if entry.isStale {
                chip("stale", color: .statusWarning)
            }
            if entry.isOversized {
                chip("large", color: .statusWarning)
            }
        }
    }

    private func chip(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.appCaption)
            .padding(.horizontal, AppSpacing.xxs + 2)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
            .foregroundStyle(color)
    }

    private var sourceColor: Color {
        switch entry.source {
        case .mainCache:   return .accentColor
        case .tmpArtifact: return Color.textSecondary
        }
    }

    private var severityColor: Color {
        switch entry.healthSeverity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }

    private var ageLabel: String {
        let d = entry.ageInDays
        if d == 0 { return "Today" }
        return "\(d)d"
    }
}
