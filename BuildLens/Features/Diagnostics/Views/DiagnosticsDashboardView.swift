import SwiftUI

struct DiagnosticsDashboardView: View {
    @Bindable var viewModel: DiagnosticsViewModel
    let summary: DiagnosticSummary

    var body: some View {
        VStack(spacing: 0) {
            DiagnosticSummaryHeader(
                summary: summary,
                onRescan: { Task { await viewModel.rescan() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    categoryFilterBar

                    DiagnosticsTimelineView(summary: summary)

                    if !viewModel.filteredCritical.isEmpty {
                        DiagnosticCategorySection(
                            title: "Critical",
                            severity: .critical,
                            issues: viewModel.filteredCritical
                        )
                    }

                    if !viewModel.filteredWarnings.isEmpty {
                        DiagnosticCategorySection(
                            title: "Warnings",
                            severity: .warning,
                            issues: viewModel.filteredWarnings
                        )
                    }

                    if summary.criticalCount == 0 && summary.warningCount == 0 {
                        allClearView
                    }

                    if !summary.healthyItems.isEmpty && !viewModel.hasActiveFilter {
                        DiagnosticCategorySection(
                            title: "Healthy",
                            severity: .healthy,
                            issues: summary.healthyItems
                        )
                    }
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }

    private var categoryFilterBar: some View {
        HStack(spacing: AppSpacing.xs) {
            filterChip(nil, label: "All")
            ForEach(DiagnosticCategory.allCases, id: \.self) { cat in
                filterChip(cat, label: cat.rawValue)
            }
            Spacer()
        }
    }

    private func filterChip(_ category: DiagnosticCategory?, label: String) -> some View {
        let isSelected = viewModel.selectedCategory == category
        return Button {
            viewModel.selectedCategory = isSelected ? nil : category
        } label: {
            Text(label)
                .font(.appCaption)
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxs + 2)
                .background(
                    isSelected ? Color.accentColor.opacity(0.15) : Color.appSurface,
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? Color.accentColor : Color.textSecondary)
        }
        .buttonStyle(.plain)
    }

    private var allClearView: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.statusHealthy)
            VStack(alignment: .leading, spacing: 2) {
                Text("All clear")
                    .font(.appTitle3)
                    .foregroundStyle(Color.textPrimary)
                Text("No critical issues or warnings detected across all subsystems.")
                    .font(.appCallout)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
