import SwiftUI

// Native macOS Table — column headers are clickable sort controls.
// Sort state lives in DerivedDataView and flows down as a Binding,
// so parent computes sortedItems and passes them in already ordered.
struct DerivedDataListView: View {
    let items: [DerivedDataItem]
    let totalSize: Int64
    @Binding var sortOrder: [KeyPathComparator<DerivedDataItem>]

    var body: some View {
        Table(items, sortOrder: $sortOrder) {
            TableColumn("Project", value: \.displayName) { item in
                ProjectCell(displayName: item.displayName, rawName: item.rawName)
            }

            TableColumn("Size", value: \.size) { item in
                SizeCell(
                    size: item.size,
                    proportion: totalSize > 0 ? Double(item.size) / Double(totalSize) : 0
                )
            }
            .width(min: 100, ideal: 130, max: 160)

            TableColumn("Last Modified", value: \.lastModified) { item in
                Text(item.lastModified.formatted(date: .abbreviated, time: .omitted))
                    .font(.appBody)
                    .foregroundStyle(Color.textSecondary)
            }
            .width(min: 110, ideal: 130, max: 155)
        }
        .tableStyle(.inset)
    }
}

// MARK: - Cell views

private struct ProjectCell: View {
    let displayName: String
    let rawName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(displayName)
                .font(.appBody)
                .foregroundStyle(Color.textPrimary)
            // Raw folder name gives power users the full Xcode hash path
            if displayName != rawName {
                Text(rawName)
                    .font(.appMonoSmall)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
}

private struct SizeCell: View {
    let size: Int64
    let proportion: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(size.formattedBytes)
                .font(.appBody)
                .foregroundStyle(Color.textPrimary)
            StorageBar(proportion: proportion)
        }
    }
}
