import SwiftUI

struct ArchiveStorageBreakdownView: View {
    let projects: [ArchiveProject]

    private var top: [ArchiveProject] {
        Array(projects.prefix(8))
    }
    private var maxStorage: Int64 { top.first?.totalStorage ?? 1 }
    private var totalStorage: Int64 { projects.reduce(0) { $0 + $1.totalStorage } }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Storage by Project")
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(totalStorage.formattedBytes)
                    .font(.appFootnote.monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
            }

            if top.isEmpty {
                Text("No archive data available")
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
            } else {
                ForEach(top) { project in
                    projectRow(project)
                }
            }
        }
        .cardStyle()
    }

    private func projectRow(_ project: ArchiveProject) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(project.projectName)
                .font(.appFootnote)
                .foregroundStyle(project.isAbandoned ? Color.statusWarning : Color.textSecondary)
                .frame(width: 140, alignment: .leading)
                .lineLimit(1)

            GeometryReader { geo in
                let fillW = maxStorage > 0
                    ? geo.size.width * CGFloat(project.totalStorage) / CGFloat(maxStorage)
                    : 0
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBorder.opacity(0.2)).frame(height: 6)
                    Capsule()
                        .fill((project.isAbandoned ? Color.statusWarning : Color.orange).opacity(0.65))
                        .frame(width: fillW, height: 6)
                }
            }
            .frame(height: 6)

            VStack(alignment: .trailing, spacing: 1) {
                Text(project.totalStorage.formattedBytes)
                    .font(.appCaption.monospacedDigit())
                    .foregroundStyle(Color.textTertiary)
                Text("\(project.archiveCount)")
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }
            .frame(width: 52, alignment: .trailing)
        }
    }
}
