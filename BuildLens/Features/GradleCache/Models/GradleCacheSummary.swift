import Foundation

struct GradleCacheSummary: Sendable {
    let totalCacheSize: Int64
    let staleCacheCount: Int
    let reclaimableStorage: Int64
    let largestCacheSection: GradleCacheEntry?
    let oldestCacheDate: Date?
    let categorySizes: [GradleCacheCategory: Int64]
    let issues: [GradleCacheIssue]

    static func build(from entries: [GradleCacheEntry]) -> GradleCacheSummary {
        let total       = entries.reduce(0) { $0 + $1.size }
        let staleCount  = entries.filter(\.isStale).count
        let reclaimable = entries.filter { $0.isStale || $0.isOversized }.reduce(0) { $0 + $1.size }
        let largest     = entries.max(by: { $0.size < $1.size })
        let oldest      = entries.min(by: { $0.lastModifiedDate < $1.lastModifiedDate })?.lastModifiedDate

        var catSizes: [GradleCacheCategory: Int64] = [:]
        for cat in GradleCacheCategory.allCases {
            catSizes[cat] = entries.filter { $0.category == cat }.reduce(0) { $0 + $1.size }
        }

        let issues = buildIssues(entries: entries, total: total, catSizes: catSizes)

        return GradleCacheSummary(
            totalCacheSize: total,
            staleCacheCount: staleCount,
            reclaimableStorage: reclaimable,
            largestCacheSection: largest,
            oldestCacheDate: oldest,
            categorySizes: catSizes,
            issues: issues.sorted { $0.severity > $1.severity }
        )
    }

    // MARK: - Issue generation

    private static func buildIssues(
        entries: [GradleCacheEntry],
        total: Int64,
        catSizes: [GradleCacheCategory: Int64]
    ) -> [GradleCacheIssue] {
        var issues: [GradleCacheIssue] = []
        let T = GradleCacheThresholds.self

        // Total size
        if total >= T.totalSizeWarning {
            issues.append(GradleCacheIssue(
                title: "Total Gradle home is \(total.formattedBytes)",
                description: "Your ~/.gradle directory has grown to \(total.formattedBytes). Stale version caches, unused wrapper distributions, and accumulated daemon logs are common causes.",
                severity: total >= T.totalSizeCritical ? .critical : .warning,
                affectedStorage: total,
                recommendation: "Clear stale Gradle version caches and unused wrapper distributions from the Clean Up tab."
            ))
        }

        // Stale version-specific caches (e.g. caches/8.14.1/ from superseded versions)
        let staleEntries = entries.filter { $0.isStale && $0.category == .caches }
        if !staleEntries.isEmpty {
            let staleStorage = staleEntries.reduce(0) { $0 + $1.size }
            issues.append(GradleCacheIssue(
                title: "\(staleEntries.count) stale cache bucket\(staleEntries.count == 1 ? "" : "s") (\(T.staleAgeDays)+ days old)",
                description: "Version-specific caches from older Gradle versions accumulate as you upgrade. They are safe to delete once the version is no longer in your wrapper files.",
                severity: staleStorage >= T.entrySizeCritical ? .critical : .warning,
                affectedStorage: staleStorage,
                recommendation: "Delete stale caches/X.Y.Z/ directories. They will be rebuilt automatically if that version is ever used again."
            ))
        }

        // Excessive wrapper distributions
        let wrapperEntries = entries.filter { $0.category == .wrapper }
        if wrapperEntries.count > T.wrapperVersionsWarning {
            let wrapperStorage = wrapperEntries.reduce(0) { $0 + $1.size }
            issues.append(GradleCacheIssue(
                title: "\(wrapperEntries.count) Gradle wrapper distributions on disk",
                description: "More than \(T.wrapperVersionsWarning) downloaded Gradle distributions suggests accumulated versions from past projects that are no longer needed.",
                severity: .warning,
                affectedStorage: wrapperStorage,
                recommendation: "Remove wrapper distributions for Gradle versions no longer referenced in any project's gradle-wrapper.properties."
            ))
        }

        // Daemon log bloat
        let daemonSize = catSizes[.daemon] ?? 0
        if daemonSize >= T.daemonSizeWarning {
            issues.append(GradleCacheIssue(
                title: "Daemon logs are \(daemonSize.formattedBytes)",
                description: "Gradle daemon log files in ~/.gradle/daemon/ have accumulated to \(daemonSize.formattedBytes). Daemon logs are safe to delete at any time.",
                severity: .warning,
                affectedStorage: daemonSize,
                recommendation: "Delete ~/.gradle/daemon/ log files. Daemon logs do not affect build functionality."
            ))
        }

        // Oversized individual entries
        for entry in entries where entry.size >= T.entrySizeCritical {
            issues.append(GradleCacheIssue(
                title: "\(entry.displayName) is \(entry.size.formattedBytes) (\(entry.category.rawValue))",
                description: "This \(entry.category.rawValue.lowercased()) entry is abnormally large and likely contains stale artifacts from many builds.",
                severity: .critical,
                affectedStorage: entry.size,
                recommendation: "Review and clear \(entry.path.path.abbreviatedPath) from the Clean Up tab."
            ))
        }

        return issues
    }

    static let empty = GradleCacheSummary(
        totalCacheSize: 0,
        staleCacheCount: 0,
        reclaimableStorage: 0,
        largestCacheSection: nil,
        oldestCacheDate: nil,
        categorySizes: [:],
        issues: []
    )
}
