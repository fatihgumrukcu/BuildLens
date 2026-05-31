import SwiftUI

struct CleanupSummaryHeader: View {
    let preview: CleanupPreview
    let isRescanning: Bool
    let onRescan: () -> Void
    let onClean: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Developer Cache Cleanup")
                        .font(.appTitle2)
                        .foregroundStyle(Color.textPrimary)

                    Text("\(preview.items.count) items found · \(preview.totalSize.formattedBytes) total")
                        .font(.appCallout)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Button(action: onRescan) {
                    if isRescanning {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("Rescan")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isRescanning)

                Button(action: onClean) {
                    if preview.selectedCount > 0 {
                        Label(
                            "Review & Clean · \(preview.selectedSize.formattedBytes)",
                            systemImage: "arrow.right.circle"
                        )
                    } else {
                        Label("Select Items to Clean", systemImage: "checkmark.square")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(preview.selectedCount == 0)
            }

            // Flow guide — shown only when the user has selected something
            if preview.selectedCount > 0 {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "1.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    Text("Review selected items below")
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.textTertiary)
                    Image(systemName: "2.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    Text("Click Review & Clean")
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.textTertiary)
                    Image(systemName: "3.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    Text("Confirm on next screen")
                }
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
            } else {
                Text("Check the boxes next to items you want to remove, then click Review & Clean.")
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(AppSpacing.contentPadding)
        .background(Color.appBackground)
    }
}
