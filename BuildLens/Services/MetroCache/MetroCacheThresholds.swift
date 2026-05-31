import Foundation

// Single source of truth for every number the Metro Cache engine uses.
// All byte thresholds use IEC units (1 GB = 1_073_741_824 bytes).
enum MetroCacheThresholds {

    // MARK: - Per-entry size
    static let entrySizeWarning:  Int64 = 500 * 1_048_576    // 500 MB
    static let entrySizeCritical: Int64 = 1 * 1_073_741_824  // 1 GB

    // MARK: - Total cache size (aligns with HealthThresholds)
    static let totalSizeWarning:  Int64 = 1 * 1_073_741_824  // 1 GB
    static let totalSizeCritical: Int64 = 3 * 1_073_741_824  // 3 GB

    // MARK: - Age
    // Main cache entries older than 30 days are unlikely to yield bundle hits.
    static let staleAgeDays:    Int = 30
    // Temporary artifacts in /tmp or user-temp should be auto-cleaned by Metro;
    // anything older than 7 days is orphaned.
    static let orphanedAgeDays: Int = 7
}
