import SwiftUI

struct WorkspaceProjectDetailView: View {
    let project: WorkspaceProject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title bar
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: project.projectType.systemImage)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.appTitle2)
                        .foregroundStyle(Color.textPrimary)
                    Text(project.url.path.abbreviatedPath)
                        .font(.appFootnote)
                        .foregroundStyle(Color.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                // Health score
                VStack(spacing: 2) {
                    Text("\(project.healthScore)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(healthColor)
                    Text("Health")
                        .font(.appCaption)
                        .foregroundStyle(Color.textTertiary)
                }

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding(AppSpacing.contentPadding)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {

                    // Storage breakdown
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        SectionHeader(title: "Storage Breakdown")
                        storageGrid
                    }

                    // Issues
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        SectionHeader(
                            title: "Issues",
                            badge: project.issueCount > 0 ? "\(project.issueCount)" : nil
                        )
                        WorkspaceIssueSection(issues: project.issues)
                            .cardStyle()
                    }

                    // Metadata
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        SectionHeader(title: "Project Info")
                        infoGrid
                    }
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .frame(minWidth: 560, minHeight: 440)
        .background(Color.appBackground)
    }

    private var storageGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
            MetricCard(title: "Total Size",   value: project.totalSize.formattedBytes,            icon: "internaldrive",  tint: .accentColor)
            MetricCard(title: "Reclaimable",  value: project.reclaimableSize.formattedBytes,      icon: "arrow.down.circle", tint: .statusWarning)
            MetricCard(title: "node_modules", value: project.nodeModulesSize > 0 ? project.nodeModulesSize.formattedBytes : "—",
                       icon: "shippingbox", tint: .orange)
            MetricCard(title: "Pods",         value: project.podsSize > 0 ? project.podsSize.formattedBytes : "—",
                       icon: "archivebox",  tint: .blue)
            MetricCard(title: "Build Artefacts", value: project.derivedDataEstimate > 0 ? project.derivedDataEstimate.formattedBytes : "—",
                       icon: "hammer",      tint: Color.textSecondary)
        }
    }

    private var infoGrid: some View {
        VStack(spacing: 0) {
            infoRow(label: "Project Type",  value: project.projectType.rawValue)
            Divider()
            infoRow(label: "Git Repository", value: project.isGitRepository ? "Yes" : "No")
            Divider()
            infoRow(label: "Last Modified",  value: project.lastModified == .distantPast ? "Unknown" : RelativeDateTimeFormatter().localizedString(for: project.lastModified, relativeTo: Date()))
            Divider()
            infoRow(label: "Full Path",      value: project.url.path)
        }
        .cardStyle()
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .frame(width: 130, alignment: .leading)
            Text(value)
                .font(.appCallout)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var healthColor: Color {
        switch project.healthSeverity {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }
}
