import SwiftUI

struct CleanupItemRow: View {
    let item: CleanupItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Toggle(isOn: Binding(
                get: { item.isSelected },
                set: { _ in onToggle() }
            )) {
                EmptyView()
            }
            .toggleStyle(.checkbox)
            .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.appBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                if !item.detail.isEmpty {
                    Text(item.detail)
                        .font(.appFootnote)
                        .foregroundStyle(Color.textTertiary)
                        .lineLimit(1)
                } else {
                    Text(item.url.path.abbreviatedPath)
                        .font(.appFootnote)
                        .foregroundStyle(Color.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            RiskLevelBadge(level: item.riskLevel)

            Text(item.size.formattedBytes)
                .font(.appCallout.monospacedDigit())
                .foregroundStyle(Color.textSecondary)
                .frame(minWidth: 64, alignment: .trailing)
        }
        .padding(.vertical, AppSpacing.xxs)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }
}
