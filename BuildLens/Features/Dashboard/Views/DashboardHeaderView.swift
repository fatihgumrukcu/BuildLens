import SwiftUI

struct DashboardHeaderView: View {
    let isLoading: Bool
    let onReload: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Dashboard")
                    .font(.appLargeTitle)
                    .foregroundStyle(Color.textPrimary)
                Text("Your dev environment at a glance")
                    .font(.appCallout)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Button(action: onReload) {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.textSecondary)
            .opacity(isLoading ? 0 : 1)
        }
    }
}
