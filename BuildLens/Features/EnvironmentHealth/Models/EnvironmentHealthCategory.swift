import Foundation

// High-level diagnostic categories for the health engine.
// Intentionally distinct from CleanupCategory — health aggregates at a higher level.
enum EnvironmentHealthCategory: String, CaseIterable, Hashable, Sendable {
    case derivedData  = "DerivedData"
    case simulators   = "Simulators"
    case caches       = "Caches"
    case archives     = "Archives"
    case nodeModules  = "Node Modules"

    var systemImage: String {
        switch self {
        case .derivedData:  return "hammer"
        case .simulators:   return "iphone"
        case .caches:       return "internaldrive"
        case .archives:     return "archivebox"
        case .nodeModules:  return "shippingbox"
        }
    }

    var scoringWeight: Double {
        switch self {
        case .derivedData:  return HealthThresholds.derivedDataWeight
        case .simulators:   return HealthThresholds.simulatorsWeight
        case .caches:       return HealthThresholds.cachesWeight
        case .archives:     return HealthThresholds.archivesWeight
        case .nodeModules:  return HealthThresholds.nodeModulesWeight
        }
    }
}
