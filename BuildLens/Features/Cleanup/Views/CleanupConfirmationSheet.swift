import SwiftUI

struct CleanupConfirmationSheet: View {
    let preview: CleanupPreview
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private var safeCount:    Int { preview.selectedItems.filter { $0.riskLevel == .safe }.count }
    private var cautionItems: [CleanupItem] { preview.selectedItems.filter { $0.riskLevel == .caution } }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Icon + title
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "trash.circle")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(Color.statusError.opacity(0.8))

                Text("Final Review")
                    .font(.appTitle2)
                    .foregroundStyle(Color.textPrimary)

                Text("\(preview.selectedCount) item\(preview.selectedCount == 1 ? "" : "s") · \(preview.selectedSize.formattedBytes) will be permanently deleted.")
                    .font(.appCallout)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            // Preview panel
            CleanupPreviewPanel(preview: preview)
                .frame(maxWidth: 440)

            // What happens after — context that makes the action less scary
            if safeCount > 0 {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "arrow.clockwise.circle")
                        .foregroundStyle(Color.statusHealthy)
                        .font(.system(size: 13))
                    Text("\(safeCount) safe item\(safeCount == 1 ? "" : "s") (DerivedData, caches) will be automatically regenerated the next time you build or run your app.")
                        .font(.appFootnote)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(AppSpacing.sm)
                .frame(maxWidth: 440, alignment: .leading)
                .background(Color.statusHealthy.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
            }

            // Caution items warning
            if !cautionItems.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.statusWarning)
                        .font(.system(size: 14))
                    Text("\(cautionItems.count) item\(cautionItems.count == 1 ? "" : "s") marked Caution (e.g. Archives) cannot be recovered after deletion. Make sure you have a backup or no longer need them.")
                        .font(.appFootnote)
                        .foregroundStyle(Color.statusWarning)
                }
                .padding(AppSpacing.sm)
                .background(Color.statusWarning.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 440)
            }

            // Actions
            HStack(spacing: AppSpacing.sm) {
                Button("Go Back", action: onCancel)
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)

                Button("Delete \(preview.selectedCount) Item\(preview.selectedCount == 1 ? "" : "s") Permanently", action: onConfirm)
                    .buttonStyle(.borderedProminent)
                    .tint(.statusError)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(AppSpacing.xxl)
        .frame(minWidth: 520)
        .background(Color.appBackground)
    }
}
