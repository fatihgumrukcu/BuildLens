import SwiftUI

struct ArchiveInsightsView: View {
    let entries: [XcodeArchiveEntry]

    private var staleCount: Int  { entries.filter(\.isStale).count }
    private var totalSize: Int64 { entries.reduce(0) { $0 + $1.size } }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                SectionHeader(title: "Archives", badge: "\(entries.count)")
                Spacer()
                if staleCount > 0 {
                    Text("\(staleCount) stale")
                        .font(.appCaption)
                        .padding(.horizontal, AppSpacing.xs - 1)
                        .padding(.vertical, 2)
                        .background(Color.statusWarning.opacity(0.1), in: Capsule())
                        .foregroundStyle(Color.statusWarning)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(entries.prefix(8)) { entry in
                    archiveRow(entry)
                    if entry.id != entries.prefix(8).last?.id {
                        Divider().padding(.leading, AppSpacing.xl)
                    }
                }
                if entries.count > 8 {
                    Text("+ \(entries.count - 8) more in Xcode Organizer")
                        .font(.appCaption)
                        .foregroundStyle(Color.textTertiary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                }
            }
            .cardStyle()
        }
    }

    private func archiveRow(_ entry: XcodeArchiveEntry) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "archivebox")
                .font(.system(size: 12))
                .foregroundStyle(entry.isStale ? Color.statusWarning : Color.textSecondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.appFootnote)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text(entry.dateGroup)
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()

            if entry.isStale {
                Text("stale")
                    .font(.appCaption)
                    .padding(.horizontal, AppSpacing.xxs + 2)
                    .padding(.vertical, 2)
                    .background(Color.statusWarning.opacity(0.1), in: Capsule())
                    .foregroundStyle(Color.statusWarning)
            }

            Text(entry.size.formattedBytes)
                .font(.appCaption.monospacedDigit())
                .foregroundStyle(Color.textTertiary)
                .frame(width: 64, alignment: .trailing)
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
    }
}
