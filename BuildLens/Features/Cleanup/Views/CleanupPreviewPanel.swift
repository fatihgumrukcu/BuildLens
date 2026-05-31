import SwiftUI

// Compact summary panel — shows what will be removed before the user triggers cleanup.
struct CleanupPreviewPanel: View {
    let preview: CleanupPreview

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Selected for Cleanup")
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)

            if preview.selectedItems.isEmpty {
                Text("No items selected.")
                    .font(.appCallout)
                    .foregroundStyle(Color.textTertiary)
            } else {
                ForEach(preview.itemsByCategory, id: \.category) { group in
                    let selected = group.items.filter(\.isSelected)
                    if !selected.isEmpty {
                        categoryRow(category: group.category, items: selected)
                    }
                }

                Divider()

                HStack {
                    Text("Total")
                        .font(.appHeadline)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Text(preview.selectedSize.formattedBytes)
                        .font(.appHeadline.monospacedDigit())
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
    }

    private func categoryRow(category: CleanupCategory, items: [CleanupItem]) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: category.systemImage)
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 16)

            Text(category.rawValue)
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text("\(items.count) item\(items.count == 1 ? "" : "s") · \(items.reduce(0) { $0 + $1.size }.formattedBytes)")
                .font(.appCallout.monospacedDigit())
                .foregroundStyle(Color.textTertiary)
        }
    }
}
