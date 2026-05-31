import Foundation

// Single source of truth for every number the Node Modules engine uses.
// All byte thresholds use IEC units (1 GB = 1_073_741_824 bytes).
enum NodeModulesThresholds {

    // MARK: - Per-project node_modules size
    static let projectSizeWarning:  Int64 = 1 * 1_073_741_824    // 1 GB
    static let projectSizeCritical: Int64 = 3 * 1_073_741_824    // 3 GB

    // MARK: - Total workspace node_modules
    static let totalSizeWarning:  Int64 = 10 * 1_073_741_824     // 10 GB
    static let totalSizeCritical: Int64 = 30 * 1_073_741_824     // 30 GB

    // MARK: - Staleness
    static let staleDays:     Int   = 90
    static let abandonedDays: Int   = 180
    static let abandonedSizeThreshold: Int64 = 500 * 1_048_576   // 500 MB

    // MARK: - Health scoring weight (must be kept in sync with HealthThresholds)
    static let scoringWeight: Double = 0.20
}
