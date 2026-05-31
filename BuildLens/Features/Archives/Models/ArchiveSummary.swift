import Foundation

struct ArchiveSummary: Sendable {
    let totalArchives: Int
    let totalStorage: Int64
    let reclaimableStorage: Int64   // stale archives excluding latest per project
    let largestArchive: ArchiveItem?
    let oldestArchive: ArchiveItem?
    let duplicateArchives: Int      // number of (project, date) groups with >1 archive
    let projects: [ArchiveProject]
    let issues: [ArchiveIssue]

    // MARK: - Factory

    static func build(from items: [ArchiveItem]) -> ArchiveSummary {
        let grouped = Dictionary(grouping: items, by: \.projectName)

        let projects: [ArchiveProject] = grouped.map { name, archives in
            let sorted = archives.sorted { $0.creationDate > $1.creationDate }
            return ArchiveProject(
                id: name, projectName: name,
                archiveCount: sorted.count,
                totalStorage: sorted.reduce(0) { $0 + $1.size },
                latestArchiveDate: sorted.first?.creationDate ?? Date.distantPast,
                oldestArchiveDate: sorted.last?.creationDate ?? Date.distantPast,
                archives: sorted
            )
        }.sorted { $0.totalStorage > $1.totalStorage }

        let total       = items.reduce(0) { $0 + $1.size }
        let latestIDs   = Set(projects.compactMap { $0.archives.first?.id })
        let staleItems  = items.filter { $0.isStale && !latestIDs.contains($0.id) }
        let reclaimable = staleItems.reduce(0) { $0 + $1.size }
        let largest     = items.max(by: { $0.size < $1.size })
        let oldest      = items.min(by: { $0.creationDate < $1.creationDate })

        let duplicateGroups = projects.reduce(0) { count, proj in
            count + proj.duplicateDateGroups.count
        }

        let issues = buildIssues(total: total, projects: projects, staleItems: staleItems, duplicates: duplicateGroups)

        return ArchiveSummary(
            totalArchives: items.count,
            totalStorage: total,
            reclaimableStorage: reclaimable,
            largestArchive: largest,
            oldestArchive: oldest,
            duplicateArchives: duplicateGroups,
            projects: projects,
            issues: issues.sorted { $0.severity > $1.severity }
        )
    }

    // MARK: - Issue generation

    private static func buildIssues(
        total: Int64,
        projects: [ArchiveProject],
        staleItems: [ArchiveItem],
        duplicates: Int
    ) -> [ArchiveIssue] {
        var issues: [ArchiveIssue] = []

        // Total size
        if total >= 50 * 1_073_741_824 {
            issues.append(ArchiveIssue(
                title: "Archive storage is \(total.formattedBytes)",
                description: "Xcode archives are consuming \(total.formattedBytes). Years of builds accumulate quickly — old releases are rarely needed for redistribution.",
                severity: .critical, affectedStorage: total,
                recommendation: "Review and delete old archives in Xcode Organizer. Keep the most recent builds for each app."
            ))
        } else if total >= 20 * 1_073_741_824 {
            issues.append(ArchiveIssue(
                title: "Archive storage at \(total.formattedBytes)",
                description: "Archives are using \(total.formattedBytes). Stale builds from completed releases can be removed safely.",
                severity: .warning, affectedStorage: total,
                recommendation: "Clear old archives from the Clean Up tab or Xcode Organizer."
            ))
        }

        // Stale archives
        if staleItems.count >= 5 {
            let staleStorage = staleItems.reduce(0) { $0 + $1.size }
            issues.append(ArchiveIssue(
                title: "\(staleItems.count) stale archives (180+ days old)",
                description: "Archives older than 180 days are likely from past releases that no longer require re-signing or dSYM lookup.",
                severity: staleItems.count >= 15 ? .critical : .warning,
                affectedStorage: staleStorage,
                recommendation: "Delete old archives from Xcode Organizer → Window → Organizer → Archives."
            ))
        }

        // Abandoned projects
        let abandoned = projects.filter(\.isAbandoned)
        if !abandoned.isEmpty {
            let abandonedStorage = abandoned.reduce(0) { $0 + $1.totalStorage }
            issues.append(ArchiveIssue(
                title: "\(abandoned.count) abandoned archive project\(abandoned.count == 1 ? "" : "s")",
                description: "Project\(abandoned.count == 1 ? "" : "s") \(abandoned.prefix(3).map(\.projectName).joined(separator: ", ")) ha\(abandoned.count == 1 ? "s" : "ve") not been archived in 365+ days.",
                severity: .warning, affectedStorage: abandonedStorage,
                recommendation: "If these projects are no longer maintained, delete their archives from Xcode Organizer."
            ))
        }

        // Duplicate groups
        if duplicates >= 3 {
            issues.append(ArchiveIssue(
                title: "\(duplicates) duplicate archive groups detected",
                description: "Multiple archives from the same project on the same day often result from failed uploads or re-signing attempts.",
                severity: .warning,
                recommendation: "Keep only the successfully uploaded archive for each release. Delete redundant builds."
            ))
        }

        return issues
    }

    static let empty = ArchiveSummary(
        totalArchives: 0, totalStorage: 0, reclaimableStorage: 0,
        largestArchive: nil, oldestArchive: nil, duplicateArchives: 0,
        projects: [], issues: []
    )
}
