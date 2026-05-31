import SwiftUI

// General-purpose storage / count metric tile.
// Used by multiple features — keeps tint configurable so each section
// can signal its domain (blue = Xcode, green = Node, orange = Android).
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 34, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.appTitle3)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.appCaption)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
        }
        .cardStyle()
    }
}
