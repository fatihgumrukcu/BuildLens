import SwiftUI

struct HealthRecommendationView: View {
    let recommendations: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Label("Recommended Actions", systemImage: "lightbulb")
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                ForEach(Array(recommendations.enumerated()), id: \.offset) { index, text in
                    recommendationRow(index: index + 1, text: text)
                }
            }
        }
        .cardStyle()
    }

    private func recommendationRow(index: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text("\(index)")
                .font(.appCaption.monospacedDigit())
                .foregroundStyle(Color.accentColor)
                .frame(width: 16, height: 16)
                .background(Color.accentColor.opacity(0.1), in: Circle())

            Text(text)
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
