import SwiftUI

struct StorageOverviewSection: View {
    let summary: DashboardSummary

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Storage")

            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                MetricCard(
                    title: "DerivedData",
                    value: summary.isLoaded ? summary.derivedDataSize.formattedBytes : "—",
                    icon: "hammer",
                    tint: .blue
                )
                MetricCard(
                    title: "npm Cache",
                    value: summary.isLoaded ? summary.npmCacheSize.formattedBytes : "—",
                    icon: "shippingbox",
                    tint: .green
                )
                MetricCard(
                    title: "Gradle Cache",
                    value: summary.isLoaded ? summary.gradleCacheSize.formattedBytes : "—",
                    icon: "square.stack.3d.down.right",
                    tint: .orange
                )
            }
        }
    }
}
