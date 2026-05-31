import SwiftUI

struct XcodeStorageBreakdownView: View {
    let summary: XcodeInfrastructureSummary

    private var maxSize: Int64 {
        summary.storageSections.first?.size ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Storage Breakdown")
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(summary.totalXcodeStorage.formattedBytes)
                    .font(.appFootnote.monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
            }

            if summary.storageSections.isEmpty {
                Text("No storage data available")
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(summary.storageSections) { section in
                        XcodeStorageSectionView(section: section, maxSize: maxSize)
                    }
                }
            }

            if summary.reclaimableStorage > 0 {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.statusWarning)
                    Text("\(summary.reclaimableStorage.formattedBytes) reclaimable via Clean Up")
                        .font(.appCaption)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.top, AppSpacing.xxs)
            }
        }
        .cardStyle()
    }
}
