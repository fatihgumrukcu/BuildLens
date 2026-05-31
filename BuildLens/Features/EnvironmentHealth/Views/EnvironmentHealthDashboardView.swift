import SwiftUI

struct EnvironmentHealthDashboardView: View {
    @Bindable var viewModel: EnvironmentHealthViewModel
    let report: EnvironmentHealthReport

    private let sectionColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            HealthScoreCard(report: report, isRescanning: viewModel.isRescanning, onRefresh: { Task { await viewModel.refresh() } })
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Issues section — always shown, empty state included
                    EnvironmentIssueList(
                        issues: viewModel.filteredIssues,
                        selectedFilter: $viewModel.selectedSeverityFilter
                    )

                    // Per-category breakdown grid
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Category Breakdown")
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)
                            .padding(.horizontal, 2)

                        LazyVGrid(columns: sectionColumns, spacing: AppSpacing.sm) {
                            ForEach(report.sections) { section in
                                EnvironmentHealthSectionView(section: section)
                            }
                        }
                    }

                    // Recommendations — only shown when there are any
                    if !report.recommendations.isEmpty {
                        HealthRecommendationView(recommendations: report.recommendations)
                    }

                    HealthTrendPlaceholderView()
                }
                .padding(AppSpacing.contentPadding)
            }
        }
        .background(Color.appBackground)
    }
}
