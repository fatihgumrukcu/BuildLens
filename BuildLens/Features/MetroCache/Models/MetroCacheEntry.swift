import Foundation

enum MetroCacheSource: String, Hashable, Sendable {
    case mainCache   = "Main Cache"
    case tmpArtifact = "Temporary"

    var systemImage: String {
        switch self {
        case .mainCache:   return "bolt.circle"
        case .tmpArtifact: return "clock.badge.xmark"
        }
    }
}

struct MetroCacheEntry: Identifiable, Hashable, Sendable {
    let id: URL
    let path: URL
    let size: Int64
    let lastModifiedDate: Date
    let source: MetroCacheSource

    // MARK: - Derived

    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: lastModifiedDate, to: Date()).day ?? 0
    }

    var isStale: Bool {
        switch source {
        case .tmpArtifact: return ageInDays >= MetroCacheThresholds.orphanedAgeDays
        case .mainCache:   return ageInDays >= MetroCacheThresholds.staleAgeDays
        }
    }

    var isOversized: Bool {
        size >= MetroCacheThresholds.entrySizeWarning
    }

    var displayName: String {
        // Shorten hash-only names (common in Metro's cache layout).
        let name = path.lastPathComponent
        return name.count > 32 ? String(name.prefix(12)) + "…" + String(name.suffix(8)) : name
    }

    var healthSeverity: EnvironmentSeverity {
        if size >= MetroCacheThresholds.entrySizeCritical { return .critical }
        if size >= MetroCacheThresholds.entrySizeWarning || isStale { return .warning }
        return .healthy
    }
}
