import Foundation

struct ArchiveItem: Identifiable, Hashable, Sendable {
    let id: URL
    let name: String              // full directory name (without .xcarchive)
    let path: URL
    let size: Int64
    let creationDate: Date        // from Info.plist CreationDate
    let modificationDate: Date    // filesystem mod date
    let projectName: String       // from Info.plist Name key
    let archiveVersion: String    // CFBundleShortVersionString, e.g. "2.4.1"
    let dateGroup: String         // the date folder, e.g. "2026-05-29"
    let uploadDestination: String? // "App Store", "TestFlight", or nil

    // MARK: - Derived

    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
    }

    // Archives older than 180 days are stale candidates.
    var isStale: Bool { ageInDays >= 180 }

    // Archives older than 365 days are likely abandoned release artifacts.
    var isAbandoned: Bool { ageInDays >= 365 }

    var wasUploaded: Bool { uploadDestination != nil }

    var healthSeverity: EnvironmentSeverity {
        if isAbandoned { return .critical }
        if isStale     { return .warning  }
        return .healthy
    }

    // Trimmed display name: strip trailing disambiguation suffixes like " 2".
    var displayName: String {
        name.trimmingCharacters(in: .whitespaces)
    }
}
