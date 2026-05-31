import SwiftUI

struct CleanupSummaryHeader: View {
    let preview: CleanupPreview
    let onRescan: () -> Void
    let onClean: () -> Void

    var body: some View {
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

            HStack(spacing: AppSpacing.sm) {
                Button("Rescan", action: onRescan)
                    .buttonStyle(.bordered)

                Button(action: onClean) {
                    if preview.selectedCount > 0 {
                        Label(
                            "Clean \(preview.selectedCount) item\(preview.selectedCount == 1 ? "" : "s") · \(preview.selectedSize.formattedBytes)",
                            systemImage: "trash"
                        )
                    } else {
                        Label("Nothing Selected", systemImage: "trash")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(preview.selectedCount == 0)
            }
        }
        .padding(AppSpacing.contentPadding)
        .background(Color.appBackground)
    }
}
