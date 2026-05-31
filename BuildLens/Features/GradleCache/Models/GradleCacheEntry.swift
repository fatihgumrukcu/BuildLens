import Foundation

struct GradleCacheEntry: Identifiable, Hashable, Sendable {
    let id: URL
    let path: URL
    let category: GradleCacheCategory
    let size: Int64
    let lastModifiedDate: Date

    // MARK: - Derived

    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: lastModifiedDate, to: Date()).day ?? 0
    }

    var isStale: Bool {
        ageInDays >= GradleCacheThresholds.staleAgeDays
    }

    var isOversized: Bool {
        size >= GradleCacheThresholds.entrySizeWarning
    }

    // Short display name — strips Gradle hash suffixes from wrapper dists.
    var displayName: String {
        path.lastPathComponent
    }

    var healthSeverity: EnvironmentSeverity {
        if size >= GradleCacheThresholds.entrySizeCritical { return .critical }
        if size >= GradleCacheThresholds.entrySizeWarning || isStale { return .warning }
        return .healthy
    }
}
