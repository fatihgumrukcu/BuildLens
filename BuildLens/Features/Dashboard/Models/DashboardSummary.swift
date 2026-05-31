import Foundation

// Aggregated read-only snapshot of the dev environment.
// Produced by DashboardViewModel.load() and consumed by dashboard subviews.
struct DashboardSummary: Sendable {
    var environmentTools: [EnvironmentTool] = []
    var derivedDataSize:   Int64 = 0
    var npmCacheSize:      Int64 = 0
    var gradleCacheSize:   Int64 = 0
    var isLoaded: Bool = false
}
