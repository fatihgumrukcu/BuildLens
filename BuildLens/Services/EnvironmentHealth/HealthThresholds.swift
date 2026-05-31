import Foundation

// Single source of truth for every number the health engine uses.
// Change values here; scoring logic auto-adjusts everywhere.
// All byte thresholds use IEC units (1 GB = 1_073_741_824 bytes).
enum HealthThresholds {

    // MARK: - DerivedData
    static let derivedDataWarning:  Int64 =  5 * 1_073_741_824  //  5 GB
    static let derivedDataCritical: Int64 = 20 * 1_073_741_824  // 20 GB

    // MARK: - Simulators
    static let unavailableSimsWarning:  Int = 2
    static let unavailableSimsCritical: Int = 5
    static let unavailableRuntimesWarning:  Int = 1
    static let unavailableRuntimesCritical: Int = 3
    static let simulatorStorageWarning:  Int64 = 10 * 1_073_741_824  // 10 GB
    static let simulatorStorageCritical: Int64 = 30 * 1_073_741_824  // 30 GB

    // MARK: - Caches
    static let metroCacheWarning:      Int64 =  1 * 1_073_741_824   //  1 GB
    static let metroCacheCritical:     Int64 =  3 * 1_073_741_824   //  3 GB
    static let gradleCacheWarning:     Int64 =  3 * 1_073_741_824   //  3 GB
    static let gradleCacheCritical:    Int64 = 10 * 1_073_741_824   // 10 GB
    static let cocoapodsCacheWarning:  Int64 =  2 * 1_073_741_824   //  2 GB
    static let cocoapodsCacheCritical: Int64 =  5 * 1_073_741_824   //  5 GB
    static let watchmanCacheWarning:   Int64 =  512 * 1_048_576     // 512 MB
    static let watchmanCacheCritical:  Int64 =  1 * 1_073_741_824   //  1 GB

    // MARK: - Archives
    static let archivesWarning:  Int64 =  5 * 1_073_741_824  //  5 GB
    static let archivesCritical: Int64 = 20 * 1_073_741_824  // 20 GB

    // MARK: - Node Modules
    static let nodeModulesWarning:  Int64 = 10 * 1_073_741_824   // 10 GB total
    static let nodeModulesCritical: Int64 = 30 * 1_073_741_824   // 30 GB total

    // MARK: - Scoring weights (must sum to 1.0)
    static let derivedDataWeight:  Double = 0.25
    static let simulatorsWeight:   Double = 0.20
    static let cachesWeight:       Double = 0.20
    static let archivesWeight:     Double = 0.15
    static let nodeModulesWeight:  Double = 0.20
}
