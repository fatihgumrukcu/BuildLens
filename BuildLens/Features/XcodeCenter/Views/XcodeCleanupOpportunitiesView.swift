import SwiftUI

struct XcodeCleanupOpportunitiesView: View {
    let summary: XcodeInfrastructureSummary

    private var opportunities: [(label: String, size: Int64, color: Color)] {
        var items: [(String, Int64, Color)] = []
        for section in summary.storageSections where section.reclaimableStorage > 0 {
            items.append((section.category.rawValue, section.reclaimableStorage, categoryColor(section.category)))
        }
        if summary.staleArchiveStorage > 0 {
            items.append(("Stale Archives (\(summary.staleArchiveCount))", summary.staleArchiveStorage, .orange))
        }
        return items.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        guard summary.reclaimableStorage > 0 || !summary.issues.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SectionHeader(title: "Cleanup Opportunities")

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    if summary.reclaimableStorage > 0 {
                        reclaimableRow
                    }
                    opportunityList
                    cleanupButton
                }
                .cardStyle()
            }
        )
    }

    private var reclaimableRow: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.statusHealthy)
                .font(.system(size: 13))
            Text("\(summary.reclaimableStorage.formattedBytes) available to reclaim safely")
                .font(.appCallout)
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.top, AppSpacing.xs)
    }

    private var opportunityList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            ForEach(opportunities, id: \.label) { item in
                HStack {
                    Circle().fill(item.color).frame(width: 6, height: 6)
                    Text(item.label)
                        .font(.appFootnote)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text(item.size.formattedBytes)
                        .font(.appCaption.monospacedDigit())
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(.horizontal, AppSpacing.sm)
            }
        }
        .padding(.vertical, AppSpacing.xxs)
    }

    private var cleanupButton: some View {
        HStack {
            Spacer()
            Text("Use the Clean Up tab to delete these safely")
                .font(.appCaption)
                .foregroundStyle(Color.textTertiary)
            Spacer()
        }
        .padding(.bottom, AppSpacing.xs)
    }

    private func categoryColor(_ cat: XcodeStorageCategory) -> Color {
        switch cat {
        case .derivedData:       return .blue
        case .archives:          return .orange
        case .simulators:        return .teal
        case .deviceSupport:     return .green
        case .documentationCache: return .purple
        }
    }
}
