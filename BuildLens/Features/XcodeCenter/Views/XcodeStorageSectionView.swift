import SwiftUI

struct XcodeStorageSectionView: View {
    let section: XcodeStorageSection
    let maxSize: Int64

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: section.category.systemImage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(categoryColor)
                .frame(width: 18)

            Text(section.category.rawValue)
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
                .frame(width: 110, alignment: .leading)

            GeometryReader { geo in
                let fillW = maxSize > 0
                    ? geo.size.width * CGFloat(section.size) / CGFloat(maxSize)
                    : 0
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBorder.opacity(0.2)).frame(height: 6)
                    Capsule().fill(categoryColor.opacity(0.7)).frame(width: fillW, height: 6)
                }
            }
            .frame(height: 6)

            VStack(alignment: .trailing, spacing: 1) {
                Text(section.size.formattedBytes)
                    .font(.appCaption.monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
                if section.itemCount > 0 {
                    Text("\(section.itemCount) item\(section.itemCount == 1 ? "" : "s")")
                        .font(.appCaption)
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .frame(width: 72, alignment: .trailing)
        }
    }

    private var categoryColor: Color {
        switch section.category {
        case .derivedData:       return .blue
        case .archives:          return .orange
        case .simulators:        return .teal
        case .deviceSupport:     return .green
        case .documentationCache: return .purple
        }
    }
}
