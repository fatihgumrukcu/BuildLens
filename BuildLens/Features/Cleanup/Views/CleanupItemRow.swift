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
                    .foregroundStyle(item.isSelected ? Color.textPrimary : Color.textSecondary)
                    .lineLimit(1)

                HStack(spacing: AppSpacing.xs) {
                    if !item.detail.isEmpty {
                        Text(item.detail)
                            .foregroundStyle(Color.textTertiary)
                    }
                    Text(item.url.path.abbreviatedPath)
                        .foregroundStyle(Color.textTertiary)
                        .truncationMode(.middle)
                        .lineLimit(1)
                }
                .font(.appFootnote)
            }

            Spacer()

            RiskLevelBadge(level: item.riskLevel)
                .help(item.riskLevel.detail)

            Text(item.size.formattedBytes)
                .font(.appCallout.monospacedDigit())
                .foregroundStyle(Color.textSecondary)
                .frame(minWidth: 64, alignment: .trailing)
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .contextMenu {
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([item.url])
            } label: {
                Label("Reveal in Finder", systemImage: "folder")
            }

            Divider()

            Button {
                onToggle()
            } label: {
                Label(
                    item.isSelected ? "Deselect" : "Select for Cleanup",
                    systemImage: item.isSelected ? "minus.square" : "checkmark.square"
                )
            }
        }
    }
}
