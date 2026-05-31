import SwiftUI

struct EnvironmentDashboardView: View {
    @Bindable var viewModel: BuildEnvironmentViewModel
    let summary: BuildEnvironmentSummary

    var body: some View {
        VStack(spacing: 0) {
            EnvironmentSummaryHeader(
                summary: summary,
                onRescan: { Task { await viewModel.rescan() } }
            )
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    filterBar

                    if !summary.allIssues.isEmpty {
                        EnvironmentIssueSection(issues: summary.allIssues)
                    }

                    EnvironmentToolListView(toolsByCategory: viewModel.toolsByCategory)
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }

    private var filterBar: some View {
        HStack(spacing: AppSpacing.sm) {
            categoryPicker
            Toggle("Issues Only", isOn: $viewModel.showOnlyIssues)
                .toggleStyle(.button)
                .controlSize(.small)
            Spacer()
        }
    }

    private var categoryPicker: some View {
        HStack(spacing: AppSpacing.xxs) {
            categoryChip(nil, label: "All")
            ForEach(BuildToolCategory.allCases, id: \.self) { cat in
                categoryChip(cat, label: String(cat.rawValue.components(separatedBy: " / ").first ?? cat.rawValue))
            }
        }
    }

    private func categoryChip(_ category: BuildToolCategory?, label: String) -> some View {
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
}
