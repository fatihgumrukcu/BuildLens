import SwiftUI

struct SimulatorDeviceRowView: View {
    let device: SimulatorDevice

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Device type icon
            Image(systemName: device.symbolName)
                .font(.title3)
                .foregroundStyle(device.isAvailable ? Color.accentColor.opacity(0.8) : Color.statusError.opacity(0.6))
                .frame(width: 28, alignment: .center)

            // Name + UDID
            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.appBody)
                    .foregroundStyle(device.isAvailable ? Color.textPrimary : Color.textSecondary)
                Text(device.udid)
                    .font(.appMonoSmall)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            // Right-side metadata column
            VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                statusBadges
                metaLine
            }
        }
        .padding(.vertical, AppSpacing.xxs)
        .opacity(device.isAvailable ? 1.0 : 0.55)
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var statusBadges: some View {
        HStack(spacing: AppSpacing.xs) {
            if device.state.isRunning {
                RunningBadge()
            }
            if !device.isAvailable {
                AvailabilityBadge(isAvailable: false)
            }
        }
    }

    private var metaLine: some View {
        HStack(spacing: AppSpacing.xs) {
            if device.storageSize > 0 {
                Text(device.storageSize.formattedBytes)
                    .font(.appCaption)
                    .foregroundStyle(Color.textSecondary)
            }
            if let date = device.lastBootedAt {
                Text("·")
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
                Text(date, style: .relative)
                    .font(.appCaption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }
}

// MARK: - Running badge (private to this file)

private struct RunningBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(Color.statusHealthy)
                .frame(width: 6, height: 6)
            Text("Running")
                .font(.appCaption)
                .foregroundStyle(Color.statusHealthy)
        }
        .padding(.horizontal, AppSpacing.xs - 2)
        .padding(.vertical, 2)
        .background(Color.statusHealthy.opacity(0.1), in: Capsule())
    }
}
