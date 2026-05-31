import Foundation

// Single source of truth for every number the Gradle Cache engine uses.
// All byte thresholds use IEC units (1 GB = 1_073_741_824 bytes).
enum GradleCacheThresholds {

    // MARK: - Per-entry size
    static let entrySizeWarning:  Int64 = 1 * 1_073_741_824   // 1 GB
    static let entrySizeCritical: Int64 = 5 * 1_073_741_824   // 5 GB

    // MARK: - Total ~/.gradle size
    static let totalSizeWarning:  Int64 = 5  * 1_073_741_824  // 5 GB
    static let totalSizeCritical: Int64 = 15 * 1_073_741_824  // 15 GB

    // MARK: - Staleness
    // Gradle version-specific caches from superseded versions are safe to delete.
    static let staleAgeDays: Int = 60

    // MARK: - Wrapper
    // More than 3 Gradle distributions on disk is rarely intentional.
    static let wrapperVersionsWarning: Int = 3

    // MARK: - Daemon
    // Daemon log accumulation above this threshold indicates missing cleanup.
    static let daemonSizeWarning: Int64 = 500 * 1_048_576     // 500 MB

    // MARK: - JDKs
    // Each auto-provisioned JDK is typically 300–600 MB.
    static let jdkEntrySizeNote: Int64 = 300 * 1_048_576      // 300 MB
}
