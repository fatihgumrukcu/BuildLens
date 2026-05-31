import Foundation

struct MetroCacheSummary: Sendable {
    let totalCacheSize: Int64
    let staleCaches: Int
    let reclaimableStorage: Int64  // storage from stale or oversized entries
    let oldestCacheDate: Date?
    let issues: [MetroCacheIssue]

    static func build(from entries: [MetroCacheEntry]) -> MetroCacheSummary {
        let total       = entries.reduce(0) { $0 + $1.size }
        let staleCount  = entries.filter(\.isStale).count
        let reclaimable = entries.filter { $0.isStale || $0.isOversized }.reduce(0) { $0 + $1.size }
        let oldest      = entries.min(by: { $0.lastModifiedDate < $1.lastModifiedDate })?.lastModifiedDate

        let issues = buildIssues(entries: entries, total: total)

        return MetroCacheSummary(
            totalCacheSize: total,
            staleCaches: staleCount,
            reclaimableStorage: reclaimable,
            oldestCacheDate: oldest,
            issues: issues.sorted { $0.severity > $1.severity }
        )
    }

    // MARK: - Issue generation

    private static func buildIssues(entries: [MetroCacheEntry], total: Int64) -> [MetroCacheIssue] {
        var issues: [MetroCacheIssue] = []
        let T = MetroCacheThresholds.self

        // Total size threshold
        if total >= T.totalSizeWarning {
            issues.append(MetroCacheIssue(
                title: "Metro cache is \(total.formattedBytes)",
                description: "The combined Metro cache is \(total.formattedBytes). Stale caches accumulate as React Native and Expo projects are opened over time.",
                severity: total >= T.totalSizeCritical ? .critical : .warning,
                affectedStorage: total,
                recommendation: "Clear the Metro cache from the Clean Up tab. Metro rebuilds it automatically on next `npx react-native start`."
            ))
        }

        // Stale main-cache entries
        let staleMain = entries.filter { $0.source == .mainCache && $0.isStale }
        if !staleMain.isEmpty {
            let staleStorage = staleMain.reduce(0) { $0 + $1.size }
            issues.append(MetroCacheIssue(
                title: "\(staleMain.count) stale cache bucket\(staleMain.count == 1 ? "" : "s") (30+ days old)",
                description: "Cache buckets untouched for \(T.staleAgeDays)+ days are unlikely to yield bundle hits and only waste disk space.",
                severity: .warning,
                affectedStorage: staleStorage,
                recommendation: "Delete stale cache buckets. Metro recreates them on demand for active projects."
            ))
        }

        // Orphaned temporary artifacts
        let orphaned = entries.filter { $0.source == .tmpArtifact && $0.isStale }
        if !orphaned.isEmpty {
            let orphanedStorage = orphaned.reduce(0) { $0 + $1.size }
            issues.append(MetroCacheIssue(
                title: "\(orphaned.count) orphaned temporary artifact\(orphaned.count == 1 ? "" : "s")",
                description: "Metro should clean up /tmp and user-temp artifacts on exit. \(orphaned.count) artifact\(orphaned.count == 1 ? " has" : "s have") been abandoned for \(T.orphanedAgeDays)+ days.",
                severity: .warning,
                affectedStorage: orphanedStorage,
                recommendation: "Safe to delete. These are leftover bundle-server state files from crashed or force-quit Metro processes."
            ))
        }

        // Oversized individual entries
        let oversized = entries.filter { $0.size >= T.entrySizeCritical }
        for entry in oversized {
            issues.append(MetroCacheIssue(
                title: "\(entry.displayName) is \(entry.size.formattedBytes)",
                description: "This Metro cache bucket is abnormally large. A single project cache exceeding 1 GB may indicate runaway transform cache growth.",
                severity: .critical,
                affectedStorage: entry.size,
                recommendation: "Delete this cache bucket. Metro will rebuild it on the next bundler run."
            ))
        }

        return issues
    }

    static let empty = MetroCacheSummary(
        totalCacheSize: 0,
        staleCaches: 0,
        reclaimableStorage: 0,
        oldestCacheDate: nil,
        issues: []
    )
}
