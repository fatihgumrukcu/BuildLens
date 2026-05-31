import Foundation

// All numeric constants for workspace analysis in one place.
// Change here; WorkspaceService adjusts automatically.
enum WorkspaceThresholds {

    // MARK: - node_modules
    static let nodeModulesWarning:  Int64 = 500 * 1_048_576   // 500 MB
    static let nodeModulesCritical: Int64 = 1 * 1_073_741_824 //   1 GB

    // MARK: - CocoaPods
    static let podsWarning:  Int64 = 500 * 1_048_576   // 500 MB
    static let podsCritical: Int64 = 2 * 1_073_741_824 //   2 GB

    // MARK: - Local build artefacts (.build/, build/, .dart_tool/)
    static let buildArtifactsWarning: Int64 = 1 * 1_073_741_824 // 1 GB

    // MARK: - Project staleness (days since last modification)
    static let staleWarningDays:  Int = 90
    static let staleCriticalDays: Int = 365

    // MARK: - Project total size
    static let largeProjectWarning:  Int64 = 5  * 1_073_741_824 //  5 GB
    static let largeProjectCritical: Int64 = 20 * 1_073_741_824 // 20 GB
}
