import SwiftUI

struct CleanupConfirmationSheet: View {
    let preview: CleanupPreview
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Icon + title
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "trash.circle")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(Color.statusError.opacity(0.8))

                Text("Confirm Cleanup")
                    .font(.appTitle2)
                    .foregroundStyle(Color.textPrimary)

                Text("The following \(preview.selectedCount) item\(preview.selectedCount == 1 ? "" : "s") (\(preview.selectedSize.formattedBytes)) will be permanently deleted.")
                    .font(.appCallout)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            // Preview panel
            CleanupPreviewPanel(preview: preview)
                .frame(maxWidth: 440)

            // Caution items warning
            let cautionItems = preview.selectedItems.filter { $0.riskLevel == .caution }
            if !cautionItems.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.statusWarning)
                        .font(.system(size: 14))
                    Text("\(cautionItems.count) item\(cautionItems.count == 1 ? "" : "s") marked Caution will be permanently deleted and cannot be recovered.")
                        .font(.appFootnote)
                        .foregroundStyle(Color.statusWarning)
                }
                .padding(AppSpacing.sm)
                .background(Color.statusWarning.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 440)
            }

            // Actions
            HStack(spacing: AppSpacing.sm) {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)

                Button("Delete \(preview.selectedCount) Item\(preview.selectedCount == 1 ? "" : "s")", action: onConfirm)
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
