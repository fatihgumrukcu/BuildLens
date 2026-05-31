import SwiftUI

// Section title row used by every feature's content area.
// Optional badge (e.g. "8/10 installed") avoids needing a separate label component.
struct SectionHeader: View {
    let title: String
    var badge: String? = nil

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Text(title)
                .font(.appTitle3)
                .foregroundStyle(Color.textPrimary)

            if let badge {
                Text(badge)
                    .font(.appCaption)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, AppSpacing.xxs + 2)
                    .padding(.vertical, 2)
                    .background(Color.appSurface, in: Capsule())
            }

            Spacer()
        }
    }
}
