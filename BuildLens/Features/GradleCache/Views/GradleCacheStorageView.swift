import SwiftUI

struct GradleCacheStorageView: View {
    let summary: GradleCacheSummary

    private var maxCategorySize: Int64 {
        summary.categorySizes.values.max() ?? 1
    }

    private var presentCategories: [(GradleCacheCategory, Int64)] {
        GradleCacheCategory.allCases
            .compactMap { cat -> (GradleCacheCategory, Int64)? in
                let size = summary.categorySizes[cat] ?? 0
                return size > 0 ? (cat, size) : nil
            }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Storage by Category")
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)

            if presentCategories.isEmpty {
                Text("No category data available")
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
            } else {
                ForEach(presentCategories, id: \.0) { category, size in
                    categoryRow(category, size: size)
                }
            }
        }
        .cardStyle()
    }

    private func categoryRow(_ category: GradleCacheCategory, size: Int64) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: category.systemImage)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(tintColor(category))
                .frame(width: 16)

            Text(category.rawValue)
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                let fillW = maxCategorySize > 0
                    ? geo.size.width * CGFloat(size) / CGFloat(maxCategorySize)
                    : 0
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBorder.opacity(0.2)).frame(height: 6)
                    Capsule().fill(tintColor(category).opacity(0.7)).frame(width: fillW, height: 6)
                }
            }
            .frame(height: 6)

            Text(size.formattedBytes)
                .font(.appCaption.monospacedDigit())
                .foregroundStyle(Color.textTertiary)
                .frame(width: 70, alignment: .trailing)
        }
    }

    private func tintColor(_ category: GradleCacheCategory) -> Color {
        switch category {
        case .caches:  return .blue
        case .wrapper: return .green
        case .daemon:  return .purple
        case .native:  return .orange
        case .jdks:    return .teal
        }
    }
}
