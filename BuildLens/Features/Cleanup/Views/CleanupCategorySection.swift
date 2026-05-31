import SwiftUI

struct CleanupCategorySection: View {
    let category: CleanupCategory
    let items: [CleanupItem]
    let onToggle: (UUID) -> Void
    let onSelectAll: () -> Void
    let onDeselectAll: () -> Void

    private var totalSize: Int64 { items.reduce(0) { $0 + $1.size } }
    private var selectedCount: Int { items.filter(\.isSelected).count }
    private var allSelected: Bool { selectedCount == items.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category header
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 18)

                Text(category.rawValue)
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)

                RiskLevelBadge(level: category.riskLevel)

                Spacer()

                Text("\(selectedCount) of \(items.count) selected · \(totalSize.formattedBytes)")
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)

                Button(allSelected ? "Deselect All" : "Select All") {
                    allSelected ? onDeselectAll() : onSelectAll()
                }
                .buttonStyle(.borderless)
                .font(.appFootnote)
                .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.top, AppSpacing.cardPadding)
            .padding(.bottom, AppSpacing.sm)

            // Hint text
            Text(category.hint)
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.bottom, AppSpacing.sm)

            Divider()
                .padding(.horizontal, AppSpacing.cardPadding)

            // Item list
            VStack(spacing: 0) {
                ForEach(items) { item in
                    CleanupItemRow(
                        item: item,
                        onToggle: { onToggle(item.id) }
                    )
                    .padding(.horizontal, AppSpacing.cardPadding)

                    if item.id != items.last?.id {
                        Divider()
                            .padding(.horizontal, AppSpacing.cardPadding)
                    }
                }
            }
            .padding(.bottom, AppSpacing.xs)
        }
        .cardStyle()
    }
}
