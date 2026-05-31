import SwiftUI

// Section header for a single runtime group.
// Shows the runtime name, total storage, device count, and a health badge.
// The unavailable runtime warning is the most important diagnostic signal — styled prominently.
struct SimulatorRuntimeSectionView: View {
    let runtime: SimulatorRuntime

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xs) {
                    Text(runtime.displayName)
                        .font(.appHeadline)
                        .foregroundStyle(Color.textPrimary)

                    if !runtime.isAvailable {
                        AvailabilityBadge(isAvailable: false)
                    }
                }

                HStack(spacing: AppSpacing.xs) {
                    Text("\(runtime.deviceCount) device\(runtime.deviceCount == 1 ? "" : "s")")
                    if runtime.totalStorageUsage > 0 {
                        Text("·")
                        Text(runtime.totalStorageUsage.formattedBytes)
                    }
                    if runtime.unavailableDeviceCount > 0 {
                        Text("·")
                        Text("\(runtime.unavailableDeviceCount) unavailable")
                            .foregroundStyle(Color.statusWarning)
                    }
                }
                .font(.appCaption)
                .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.xxs)
    }
}
