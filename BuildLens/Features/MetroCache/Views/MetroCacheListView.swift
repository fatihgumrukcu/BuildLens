import SwiftUI

struct MetroCacheListView: View {
    let entries: [MetroCacheEntry]
    let totalEntries: Int

    private var maxSize: Int64 {
        entries.first?.size ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(
                title: "Cache Entries",
                badge: entries.count == totalEntries
                    ? "\(totalEntries)"
                    : "\(entries.count) of \(totalEntries)"
            )

            if entries.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(Color.textTertiary)
                    Text("No entries match the active filter.")
                        .font(.appCallout)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(entries) { entry in
                        MetroCacheRowView(entry: entry, maxSize: maxSize)
                        if entry.id != entries.last?.id {
                            Divider().padding(.leading, AppSpacing.xl + AppSpacing.xs)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
}
