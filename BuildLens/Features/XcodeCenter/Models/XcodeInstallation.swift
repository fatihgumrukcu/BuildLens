import Foundation

struct XcodeInstallation: Sendable {
    let version: String        // e.g., "16.2"
    let buildVersion: String   // e.g., "16C5032a"
    let developerPath: String  // from xcode-select -p
    let isActive: Bool

    // Scanning /Applications/Xcode.app can take 10-30 s on large installations.
    // Size is computed lazily on demand; nil here means "not yet calculated."
    let installationSize: Int64?

    var displayVersion: String { "Xcode \(version)" }
    var shortPath: String { developerPath.replacingOccurrences(of: "/Contents/Developer", with: "") }
}
