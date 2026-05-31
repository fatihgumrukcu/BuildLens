import Foundation

struct XcodeInfrastructureSummary: Sendable {
    let activeXcodeVersion: String?
    let totalXcodeStorage: Int64
    let reclaimableStorage: Int64
    let archiveCount: Int
    let simulatorCount: Int
    let derivedDataCount: Int
    let installation: XcodeInstallation?
    let storageSections: [XcodeStorageSection]
    let archiveEntries: [XcodeArchiveEntry]
    let deviceSupportEntries: [XcodeDeviceSupportEntry]
    let issues: [XcodeStorageIssue]

    // MARK: - Convenience

    func section(for category: XcodeStorageCategory) -> XcodeStorageSection? {
        storageSections.first { $0.category == category }
    }

    var staleArchiveCount: Int { archiveEntries.filter(\.isStale).count }
    var staleArchiveStorage: Int64 { archiveEntries.filter(\.isStale).reduce(0) { $0 + $1.size } }

    // MARK: - Factory

    static func build(
        installation: XcodeInstallation?,
        sections: [XcodeStorageSection],
        archiveEntries: [XcodeArchiveEntry],
        deviceSupportEntries: [XcodeDeviceSupportEntry]
    ) -> XcodeInfrastructureSummary {
        let total      = sections.reduce(0) { $0 + $1.size }
        let reclaimable = sections.reduce(0) { $0 + $1.reclaimableStorage }
        let ddCount    = sections.first(where: { $0.category == .derivedData })?.itemCount ?? 0
        let archCount  = archiveEntries.count
        let simCount   = sections.first(where: { $0.category == .simulators })?.itemCount ?? 0
        let issues     = buildIssues(total: total, sections: sections, archives: archiveEntries)

        return XcodeInfrastructureSummary(
            activeXcodeVersion: installation?.displayVersion,
            totalXcodeStorage: total,
            reclaimableStorage: reclaimable,
            archiveCount: archCount,
            simulatorCount: simCount,
            derivedDataCount: ddCount,
            installation: installation,
            storageSections: sections.sorted { $0.size > $1.size },
            archiveEntries: archiveEntries.sorted { $0.size > $1.size },
            deviceSupportEntries: deviceSupportEntries.sorted { $0.size > $1.size },
            issues: issues.sorted { $0.severity > $1.severity }
        )
    }

    // MARK: - Issue generation

    private static func buildIssues(
        total: Int64,
        sections: [XcodeStorageSection],
        archives: [XcodeArchiveEntry]
    ) -> [XcodeStorageIssue] {
        var issues: [XcodeStorageIssue] = []

        if total >= 60 * 1_073_741_824 {
            issues.append(XcodeStorageIssue(
                title: "Xcode consuming \(total.formattedBytes) of storage",
                description: "Combined Xcode storage has reached \(total.formattedBytes). DerivedData and simulator runtimes are the most common causes.",
                severity: .critical, affectedStorage: total,
                recommendation: "Use the Clean Up tab to clear DerivedData and remove unused simulator runtimes.",
                category: .derivedData
            ))
        } else if total >= 20 * 1_073_741_824 {
            issues.append(XcodeStorageIssue(
                title: "Xcode storage at \(total.formattedBytes)",
                description: "Combined Xcode storage is \(total.formattedBytes). Regular cleanup keeps builds fast and disks healthy.",
                severity: .warning, affectedStorage: total,
                recommendation: "Clean DerivedData and review archive history in the Clean Up tab.",
                category: .derivedData
            ))
        }

        let staleArchives = archives.filter(\.isStale)
        if !staleArchives.isEmpty {
            let staleStorage = staleArchives.reduce(0) { $0 + $1.size }
            issues.append(XcodeStorageIssue(
                title: "\(staleArchives.count) archive\(staleArchives.count == 1 ? "" : "s") older than 180 days",
                description: "Old distribution archives accumulate after each App Store or TestFlight submission.",
                severity: .warning, affectedStorage: staleStorage,
                recommendation: "Review old archives in Xcode Organizer and delete builds you no longer need for re-signing.",
                category: .archives
            ))
        }

        if let ds = sections.first(where: { $0.category == .deviceSupport }), ds.size >= 5 * 1_073_741_824 {
            issues.append(XcodeStorageIssue(
                title: "Device Support files are \(ds.size.formattedBytes)",
                description: "Device Support files are downloaded automatically when you connect a device. Older OS versions may no longer be needed.",
                severity: .warning, affectedStorage: ds.size,
                recommendation: "Remove device support files for iOS versions you no longer target or test on.",
                category: .deviceSupport
            ))
        }

        return issues
    }

    static let empty = XcodeInfrastructureSummary(
        activeXcodeVersion: nil, totalXcodeStorage: 0, reclaimableStorage: 0,
        archiveCount: 0, simulatorCount: 0, derivedDataCount: 0,
        installation: nil, storageSections: [], archiveEntries: [],
        deviceSupportEntries: [], issues: []
    )
}
