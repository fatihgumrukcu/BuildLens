import SwiftUI

struct XcodeVersionCard: View {
    let installation: XcodeInstallation?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                Text("Active Xcode")
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                if installation != nil {
                    Text("Active")
                        .font(.appCaption)
                        .padding(.horizontal, AppSpacing.xs - 1)
                        .padding(.vertical, 2)
                        .background(Color.statusHealthy.opacity(0.12), in: Capsule())
                        .foregroundStyle(Color.statusHealthy)
                }
            }

            if let inst = installation {
                HStack(spacing: AppSpacing.xl) {
                    versionColumn("Version", value: inst.displayVersion)
                    versionColumn("Build", value: inst.buildVersion)
                }

                Text(inst.shortPath)
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
            } else {
                Text("Xcode not found — install from the Mac App Store.")
                    .font(.appCallout)
                    .foregroundStyle(Color.statusWarning)
            }
        }
        .cardStyle()
    }

    private func versionColumn(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.appTitle3)
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.appCaption)
                .foregroundStyle(Color.textTertiary)
        }
    }
}
