import Charts
import SwiftUI

struct HealthTrendView: View {

    let refreshID: Date

    @State private var history: [HealthSnapshot] = []
    @State private var range: TrendRange = .thirtyDays

    enum TrendRange: String, CaseIterable {
        case sevenDays  = "7d"
        case thirtyDays = "30d"
        case all        = "All"
    }

    private var filtered: [HealthSnapshot] {
        let cutoff: Date
        switch range {
        case .sevenDays:
            cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .thirtyDays:
            cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        case .all:
            cutoff = .distantPast
        }
        return history.filter { $0.date >= cutoff }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            headerRow

            if filtered.count < 2 {
                emptyState
            } else {
                chartView
                    .padding(.top, AppSpacing.xxs)
                statsRow
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                .strokeBorder(Color.appBorder.opacity(0.4), lineWidth: 0.5)
        )
        .onAppear { history = HealthHistoryService.load() }
        .onChange(of: refreshID) { history = HealthHistoryService.load() }
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack {
            Label("Health Trend", systemImage: "chart.line.uptrend.xyaxis")
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            if history.count >= 2 {
                Picker("Range", selection: $range) {
                    ForEach(TrendRange.allCases, id: \.self) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 130)
                .controlSize(.small)
            }
        }
    }

    private var emptyState: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(Color.textTertiary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Trend tracking starts here")
                    .font(.appBody)
                    .foregroundStyle(Color.textSecondary)
                Text("Each scan records a data point. Scan again on a different day to see your first trend.")
                    .font(.appFootnote)
                    .foregroundStyle(Color.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var chartView: some View {
        Chart(filtered) { snap in
            AreaMark(
                x: .value("Date", snap.date),
                y: .value("Score", snap.score)
            )
            .foregroundStyle(Color.accentColor.opacity(0.07))
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Date", snap.date),
                y: .value("Score", snap.score)
            )
            .foregroundStyle(Color.accentColor.opacity(0.7))
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2))

            PointMark(
                x: .value("Date", snap.date),
                y: .value("Score", snap.score)
            )
            .foregroundStyle(pointColor(snap.status))
            .symbolSize(32)
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: [0, 50, 100]) { _ in
                AxisGridLine().foregroundStyle(Color.appBorder.opacity(0.3))
                AxisValueLabel().foregroundStyle(Color.textTertiary)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .frame(height: 100)
    }

    private var statsRow: some View {
        let scores = filtered.map(\.score)
        let latest = scores.last ?? 0
        let first  = scores.first ?? latest
        let delta  = latest - first
        let avg    = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count

        return HStack(spacing: AppSpacing.lg) {
            statCell(label: "Latest",  value: "\(latest)", color: scoreColor(latest))
            statCell(label: "Change",  value: delta == 0 ? "±0" : delta > 0 ? "+\(delta)" : "\(delta)",
                     color: delta > 0 ? .statusHealthy : delta < 0 ? .statusError : Color.textSecondary)
            statCell(label: "Average", value: "\(avg)",    color: scoreColor(avg))

            Spacer()

            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: trendIcon(delta))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(trendColor(delta))
                Text(trendLabel(delta))
                    .font(.appFootnote)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private func statCell(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.appCaption)
                .foregroundStyle(Color.textTertiary)
            Text(value)
                .font(.appBody.monospacedDigit())
                .foregroundStyle(color)
        }
    }

    // MARK: - Helpers

    private func pointColor(_ status: EnvironmentSeverity) -> Color {
        switch status {
        case .healthy:  return .statusHealthy
        case .warning:  return .statusWarning
        case .critical: return .statusError
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return .statusHealthy }
        if score >= 60 { return .statusWarning }
        return .statusError
    }

    private func trendIcon(_ delta: Int) -> String {
        if delta >  5 { return "arrow.up.right" }
        if delta < -5 { return "arrow.down.right" }
        return "arrow.right"
    }

    private func trendColor(_ delta: Int) -> Color {
        if delta >  5 { return .statusHealthy }
        if delta < -5 { return .statusError }
        return Color.textSecondary
    }

    private func trendLabel(_ delta: Int) -> String {
        if delta >  5 { return "Improving" }
        if delta < -5 { return "Declining" }
        return "Stable"
    }
}
