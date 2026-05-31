import Foundation

// All navigable screens in one place.
// Adding a new screen = add a case here + route it in DetailRouterView.
enum AppDestination: String, CaseIterable, Hashable, Identifiable {
    // Overview
    case dashboard
    case environmentHealth
    case workspaceIntelligence

    // Xcode & iOS
    case derivedData
    case simulators
    case archives
    case xcodeCache

    // React Native
    case nodeModules
    case metroCache

    // Android
    case gradleCache

    // System
    case buildEnvironment
    case diagnostics

    // Cleanup
    case cleanupEngine

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:              return "Dashboard"
        case .environmentHealth:      return "Environment Health"
        case .workspaceIntelligence:  return "Workspace"
        case .derivedData:      return "DerivedData"
        case .simulators:       return "Simulators"
        case .archives:         return "Archives"
        case .xcodeCache:       return "Xcode Cache"
        case .nodeModules:      return "Node Modules"
        case .metroCache:       return "Metro Cache"
        case .gradleCache:      return "Gradle Cache"
        case .buildEnvironment: return "Environment"
        case .diagnostics:      return "Diagnostics"
        case .cleanupEngine:    return "Clean Up"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:             return "square.grid.2x2"
        case .environmentHealth:     return "heart.text.clipboard"
        case .workspaceIntelligence: return "folder.badge.gearshape"
        case .derivedData:      return "hammer"
        case .simulators:       return "iphone"
        case .archives:         return "archivebox"
        case .xcodeCache:       return "wrench.and.screwdriver"
        case .nodeModules:      return "shippingbox"
        case .metroCache:       return "bolt"
        case .gradleCache:      return "square.stack.3d.down.right"
        case .buildEnvironment: return "terminal"
        case .diagnostics:      return "stethoscope"
        case .cleanupEngine:    return "trash.slash"
        }
    }

    var category: SidebarCategory {
        switch self {
        case .dashboard, .environmentHealth, .workspaceIntelligence:
            return .overview
        case .derivedData, .simulators, .archives, .xcodeCache:
            return .xcode
        case .nodeModules, .metroCache:
            return .reactNative
        case .gradleCache:
            return .android
        case .buildEnvironment, .diagnostics:
            return .system
        case .cleanupEngine:
            return .cleanup
        }
    }
}

enum SidebarCategory: String, CaseIterable {
    case overview    = "Overview"
    case xcode       = "Xcode & iOS"
    case reactNative = "React Native"
    case android     = "Android"
    case system      = "System"
    case cleanup     = "Clean Up"

    var destinations: [AppDestination] {
        AppDestination.allCases.filter { $0.category == self }
    }
}
