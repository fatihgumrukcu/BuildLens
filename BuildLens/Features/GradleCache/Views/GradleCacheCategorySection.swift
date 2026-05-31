import SwiftUI

struct GradleCacheCategorySection: View {
    let category: GradleCacheCategory
    let entries: [GradleCacheEntry]

    private var maxSize: Int64 { entries.first?.size ?? 1 }
    private var totalSize: Int64 { entries.reduce(0) { $0 + $1.size } }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            categoryHeader
            entryList
        }
    }

    private var categoryHeader: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: category.systemImage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(categoryColor)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(category.rawValue)
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
                Text(category.description)
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Text(totalSize.formattedBytes)
                .font(.appFootnote.monospacedDigit())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var entryList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(entries) { entry in
                GradleCacheRowView(entry: entry, maxSize: maxSize)
                if entry.id != entries.last?.id {
                    Divider().padding(.leading, AppSpacing.xl + AppSpacing.xs)
                }
            }
        }
        .cardStyle()
    }

    private var categoryColor: Color {
        switch category {
        case .caches:  return .blue
        case .wrapper: return .green
        case .daemon:  return .purple
        case .native:  return .orange
        case .jdks:    return .teal
        }
    }
}
