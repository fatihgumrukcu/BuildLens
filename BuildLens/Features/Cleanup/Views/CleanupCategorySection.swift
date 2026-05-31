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
                    .foregroundStyle(riskColor)
                    .frame(width: 18)

                Text(category.rawValue)
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)

                RiskLevelBadge(level: category.riskLevel)
                    .help(category.riskLevel.detail)

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
            .padding(.bottom, AppSpacing.xs)

            // Hint box — coloured by risk level so the consequence is immediately obvious
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: riskIcon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(riskColor)
                Text(category.hint)
                    .font(.appFootnote)
                    .foregroundStyle(riskColor.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(riskColor.opacity(0.07), in: Rectangle())

            Divider()

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

    private var riskColor: Color {
        switch category.riskLevel {
        case .safe:     return .statusHealthy
        case .moderate: return .statusWarning
        case .caution:  return .statusError
        }
    }

    private var riskIcon: String {
        switch category.riskLevel {
        case .safe:     return "checkmark.circle"
        case .moderate: return "exclamationmark.circle"
        case .caution:  return "exclamationmark.triangle"
        }
    }
}
