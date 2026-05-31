import SwiftUI

struct ArchiveRowView: View {
    let archive: ArchiveItem

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Status icon
            Image(systemName: archive.wasUploaded ? "arrow.up.circle.fill" : "archivebox")
                .font(.system(size: 12))
                .foregroundStyle(statusColor)
                .frame(width: 18)

            // Name + version
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xxs) {
                    if !archive.archiveVersion.isEmpty {
                        Text("v\(archive.archiveVersion)")
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)
                    }
                    badges
                }
                Text(archive.dateGroup)
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()

            // Upload destination
            if let dest = archive.uploadDestination {
                Text(dest)
                    .font(.appCaption)
                    .padding(.horizontal, AppSpacing.xxs + 2)
                    .padding(.vertical, 2)
                    .background(Color.statusHealthy.opacity(0.1), in: Capsule())
                    .foregroundStyle(Color.statusHealthy)
            }

            // Age + size
            VStack(alignment: .trailing, spacing: 2) {
                Text(archive.size.formattedBytes)
                    .font(.appCaption.monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
                Text("\(archive.ageInDays)d ago")
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
    }

    private var badges: some View {
        HStack(spacing: AppSpacing.xxs) {
            if archive.isAbandoned {
                badgeView("abandoned", color: .statusError)
            } else if archive.isStale {
                badgeView("stale", color: .statusWarning)
            }
        }
    }

    private func badgeView(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.appCaption)
            .padding(.horizontal, AppSpacing.xxs + 2)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
            .foregroundStyle(color)
    }

    private var statusColor: Color {
        if archive.wasUploaded   { return .statusHealthy }
        if archive.isAbandoned   { return .statusError   }
        if archive.isStale       { return .statusWarning }
        return Color.textSecondary
    }
}
