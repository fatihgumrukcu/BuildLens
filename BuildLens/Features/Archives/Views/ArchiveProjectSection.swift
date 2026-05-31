import SwiftUI

struct ArchiveProjectSection: View {
    let project: ArchiveProject
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            projectHeader
            if isExpanded { archiveList }
        }
    }

    private var projectHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
                    .frame(width: 12)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: AppSpacing.xs) {
                        Text(project.projectName)
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)
                        if project.isAbandoned {
                            Text("abandoned")
                                .font(.appCaption)
                                .padding(.horizontal, AppSpacing.xxs + 2)
                                .padding(.vertical, 2)
                                .background(Color.statusWarning.opacity(0.1), in: Capsule())
                                .foregroundStyle(Color.statusWarning)
                        }
                    }
                    HStack(spacing: AppSpacing.xs) {
                        Text("\(project.archiveCount) archive\(project.archiveCount == 1 ? "" : "s")")
                        Text("·")
                        Text(project.totalStorage.formattedBytes)
                        Text("·")
                        Text("Latest \(project.daysSinceLatest)d ago")
                    }
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
                }

                Spacer()

                if project.staleCount > 0 {
                    Text("\(project.staleCount) stale")
                        .font(.appCaption)
                        .foregroundStyle(Color.statusWarning)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var archiveList: some View {
        VStack(alignment: .leading, spacing: 0) {
            let shown = Array(project.archives.prefix(6))
            ForEach(shown) { archive in
                ArchiveRowView(archive: archive)
                if archive.id != shown.last?.id {
                    Divider().padding(.leading, AppSpacing.xl)
                }
            }
            if project.archiveCount > 6 {
                Text("+ \(project.archiveCount - 6) more — view all in Xcode Organizer")
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
            }
        }
        .cardStyle()
    }
}
