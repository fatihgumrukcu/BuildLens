import Foundation

// MARK: - Archive Entry

struct XcodeArchiveEntry: Identifiable, Hashable, Sendable {
    let id: URL
    let path: URL
    let name: String      // display name from the .xcarchive directory
    let size: Int64
    let dateGroup: String // the date-folder name, e.g. "2025-03-11"
    let modifiedDate: Date

    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: modifiedDate, to: Date()).day ?? 0
    }

    // Archives older than 180 days are likely from superseded builds.
    var isStale: Bool { ageInDays >= 180 }

    // Strip ".xcarchive" suffix and any timestamp from the display name.
    var displayName: String {
        name.replacingOccurrences(of: ".xcarchive", with: "")
    }
}

// MARK: - Device Support Entry

// Device support entries use Xcode's naming: "<ModelID> <OSVersion> (<Build>)"
// e.g. "iPhone14,8 26.3.1 (23D771330a)"
struct XcodeDeviceSupportEntry: Identifiable, Hashable, Sendable {
    let id: URL
    let path: URL
    let rawName: String   // full directory name from filesystem
    let size: Int64
    let modifiedDate: Date

    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: modifiedDate, to: Date()).day ?? 0
    }

    // Device support files older than 2 years rarely correspond to active devices.
    var isLikelyUnused: Bool { ageInDays >= 730 }
}
