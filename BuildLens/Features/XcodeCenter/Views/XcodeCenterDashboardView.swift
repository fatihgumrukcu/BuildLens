import SwiftUI

struct XcodeCenterDashboardView: View {
    let viewModel: XcodeCenterViewModel
    let summary: XcodeInfrastructureSummary

    var body: some View {
        VStack(spacing: 0) {
            XcodeInfrastructureHeader(
                summary: summary,
                onReload: { Task { await viewModel.reload() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    XcodeVersionCard(installation: summary.installation)

                    XcodeStorageBreakdownView(summary: summary)

                    if !summary.issues.isEmpty {
                        issueSection
                    }

                    if !summary.archiveEntries.isEmpty {
                        ArchiveInsightsView(entries: summary.archiveEntries)
                    }

                    if !summary.deviceSupportEntries.isEmpty,
                       let dsSection = summary.section(for: .deviceSupport) {
                        DeviceSupportView(entries: summary.deviceSupportEntries, section: dsSection)
                    }

                    if let docSection = summary.section(for: .documentationCache) {
                        DocumentationCacheView(section: docSection)
                    }

                    XcodeCleanupOpportunitiesView(summary: summary)
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }

    private var issueSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Issues", badge: "\(summary.issues.count)")

            VStack(alignment: .leading, spacing: 0) {
                ForEach(summary.issues) { issue in
                    issueRow(issue)
                    if issue.id != summary.issues.last?.id {
                        Divider().padding(.leading, AppSpacing.xl)
                    }
                }
            }
            .cardStyle()
        }
    }

    private func issueRow(_ issue: XcodeStorageIssue) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: issue.severity.systemImage)
                .font(.system(size: 13))
                .foregroundStyle(severityColor(issue.severity))
                .frame(width: 18, alignment: .top)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack {
                    Text(issue.title).font(.appBody).foregroundStyle(Color.textPrimary)
                    Spacer()
                    if issue.affectedStorage > 0 {
                        Text(issue.affectedStorage.formattedBytes)
                            .font(.appFootnote.monospacedDigit()).foregroundStyle(Color.textTertiary)
                    }
                }
                Text(issue.recommendation).font(.appFootnote).foregroundStyle(Color.accentColor.opacity(0.8))
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
    }

    private func severityColor(_ s: EnvironmentSeverity) -> Color {
        switch s {
        case .healthy: return .statusHealthy
        case .warning: return .statusWarning
        case .critical: return .statusError
        }
    }
}
