import SwiftUI

struct DeviceSupportView: View {
    let entries: [XcodeDeviceSupportEntry]
    let section: XcodeStorageSection

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Device Support", badge: "\(entries.count) versions")

            VStack(alignment: .leading, spacing: 0) {
                ForEach(entries.prefix(8)) { entry in
                    deviceRow(entry)
                    if entry.id != entries.prefix(8).last?.id {
                        Divider().padding(.leading, AppSpacing.xl)
                    }
                }
                if entries.count > 8 {
                    Text("+ \(entries.count - 8) more")
                        .font(.appCaption)
                        .foregroundStyle(Color.textTertiary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                }
            }
            .cardStyle()

            Text("Device Support files are downloaded automatically when you connect a device running a new OS version. Files for devices you no longer use can be deleted safely.")
                .font(.appCaption)
                .foregroundStyle(Color.textTertiary)
        }
    }

    private func deviceRow(_ entry: XcodeDeviceSupportEntry) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "cable.connector")
                .font(.system(size: 12))
                .foregroundStyle(entry.isLikelyUnused ? Color.statusWarning : .green)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.rawName)
                    .font(.appFootnote)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text("\(entry.ageInDays)d ago")
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()

            if entry.isLikelyUnused {
                Text("old")
                    .font(.appCaption)
                    .padding(.horizontal, AppSpacing.xxs + 2)
                    .padding(.vertical, 2)
                    .background(Color.statusWarning.opacity(0.1), in: Capsule())
                    .foregroundStyle(Color.statusWarning)
            }

            Text(entry.size.formattedBytes)
                .font(.appCaption.monospacedDigit())
                .foregroundStyle(Color.textTertiary)
                .frame(width: 64, alignment: .trailing)
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
    }
}
