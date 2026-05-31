import Foundation

// Allowlist-based deletion guard. Every path passed to FileManager.removeItem
// must pass through here first. No path outside the explicit allowlist can be deleted.
struct CleanupValidator: Sendable {

    private static let allowedPrefixes: [String] = [
        "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData/",
        "\(NSHomeDirectory())/Library/Developer/CoreSimulator/Devices/",
        "\(NSHomeDirectory())/Library/Developer/CoreSimulator/Runtimes/",
        "\(NSHomeDirectory())/Library/Developer/Xcode/Archives/",
        "\(NSHomeDirectory())/Library/Caches/CocoaPods/",
        "\(NSHomeDirectory())/Library/Caches/Metro/",
        "\(NSHomeDirectory())/Library/Caches/com.github.facebook.watchman/",
        "\(NSHomeDirectory())/.gradle/caches/",
        "\(NSHomeDirectory())/.npm/",
    ]

    // Root directories in the allowlist that must never themselves be deleted.
    private static let blockedExact: Set<String> = [
        NSHomeDirectory(),
        "\(NSHomeDirectory())/Library",
        "\(NSHomeDirectory())/Library/Developer",
        "\(NSHomeDirectory())/Library/Developer/Xcode",
        "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData",
        "\(NSHomeDirectory())/Library/Developer/CoreSimulator",
        "\(NSHomeDirectory())/Library/Developer/CoreSimulator/Devices",
        "\(NSHomeDirectory())/Library/Developer/CoreSimulator/Runtimes",
        "\(NSHomeDirectory())/Library/Developer/Xcode/Archives",
        "\(NSHomeDirectory())/Library/Caches",
        "\(NSHomeDirectory())/Library/Caches/CocoaPods",
        "\(NSHomeDirectory())/Library/Caches/Metro",
        "\(NSHomeDirectory())/Library/Caches/com.github.facebook.watchman",
        "\(NSHomeDirectory())/.gradle",
        "\(NSHomeDirectory())/.gradle/caches",
        "\(NSHomeDirectory())/.npm",
        "/",
        "/System",
        "/Library",
        "/usr",
        "/bin",
        "/Applications",
    ]

    enum ValidationError: Error, LocalizedError {
        case emptyPath
        case rootPath
        case pathTooShort
        case notUnderAllowedPrefix(String)
        case blockedRootDirectory(String)

        var errorDescription: String? {
            switch self {
            case .emptyPath:
                return "Path is empty."
            case .rootPath:
                return "Refusing to operate on the filesystem root."
            case .pathTooShort:
                return "Path is too short to be a valid developer cache entry."
            case .notUnderAllowedPrefix(let p):
                return "Path is not in an approved developer cache location: \(p)"
            case .blockedRootDirectory(let p):
                return "Refusing to delete a protected root directory: \(p)"
            }
        }
    }

    func validate(_ url: URL) throws {
        let path = url.path

        guard !path.isEmpty else { throw ValidationError.emptyPath }
        guard path != "/" else { throw ValidationError.rootPath }
        guard path.count > 20 else { throw ValidationError.pathTooShort }

        guard !Self.blockedExact.contains(path) else {
            throw ValidationError.blockedRootDirectory(path)
        }

        // Android project build outputs are allowed anywhere under the home dir,
        // provided the path contains the known build subfolder markers.
        if Self.isAndroidBuildOutput(path) { return }

        // Standard developer cache allowlist
        let normalised = path.hasSuffix("/") ? path : path + "/"
        guard Self.allowedPrefixes.contains(where: { normalised.hasPrefix($0) }) else {
            throw ValidationError.notUnderAllowedPrefix(path)
        }
    }

    // Path must be under home and contain a known Android build output subfolder.
    private static func isAndroidBuildOutput(_ path: String) -> Bool {
        guard path.hasPrefix(NSHomeDirectory()), path.count > 40 else { return false }
        let markers = ["/android/app/build/outputs", "/android/app/build/intermediates"]
        return markers.contains { path.contains($0) }
    }
}
