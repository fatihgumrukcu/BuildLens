import SwiftUI

struct DerivedDataSummaryHeader: View {
    let totalSize: Int64
    let itemCount: Int
    let isRescanning: Bool
    let onRescan: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("DerivedData")
                    .font(.appLargeTitle)
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: AppSpacing.sm) {
                    Label(totalSize.formattedBytes, systemImage: "internaldrive")
                    Text("·")
                    Text(itemCount == 1 ? "1 project" : "\(itemCount) projects")
                }
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Button(action: onRescan) {
                if isRescanning {
                    ProgressView().controlSize(.small)
                } else {
                    Label("Rescan", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .disabled(isRescanning)
        }
    }
}
