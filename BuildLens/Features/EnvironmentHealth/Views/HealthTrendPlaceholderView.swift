import SwiftUI

private struct WaveBarView: View {
    let index: Int
    let value: Int

    private var barOpacity: Double { 0.15 + Double(index) * 0.05 }
    private var barHeight: CGFloat { CGFloat(value) * 0.6 }

    var body: some View {
        Capsule()
            .fill(Color.accentColor.opacity(barOpacity))
            .frame(height: barHeight)
            .frame(maxWidth: .infinity)
    }
}

// Reserved space for future historical trend analysis.
// When historical tracking is implemented, this becomes a sparkline chart
// showing environment health score over time.
struct HealthTrendPlaceholderView: View {
    private let waveValues = [72, 68, 75, 71, 74, 69, 72, 78, 75, 72, 68, 65]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label("Health Trend", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.appHeadline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Text("Coming Soon")
                    .font(.appCaption)
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.textTertiary.opacity(0.12), in: Capsule())
                    .foregroundStyle(Color.textTertiary)
            }

            Text("Historical health tracking will display environment score trends across sessions, helping you identify patterns in build artefact accumulation and cache growth.")
                .font(.appFootnote)
                .foregroundStyle(Color.textTertiary)
                .fixedSize(horizontal: false, vertical: true)

            // Placeholder waveform
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(waveValues.indices, id: \.self) { i in
                    WaveBarView(index: i, value: waveValues[i])
                }
            }
            .frame(height: 50)
            .padding(.top, AppSpacing.xs)
        }
        .padding(AppSpacing.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                .strokeBorder(Color.appBorder.opacity(0.4), lineWidth: 0.5)
        )
    }
}
