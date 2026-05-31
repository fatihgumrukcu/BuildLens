import Foundation

enum DiagnosticCategory: String, CaseIterable, Hashable, Sendable {
    case xcode       = "Xcode"
    case javascript  = "JavaScript"
    case android     = "Android"
    case workspace   = "Workspace"
    case environment = "Environment"

    var systemImage: String {
        switch self {
        case .xcode:       return "hammer.fill"
        case .javascript:  return "atom"
        case .android:     return "square.stack.3d.down.right.fill"
        case .workspace:   return "folder.badge.gearshape"
        case .environment: return "terminal"
        }
    }

    var description: String {
        switch self {
        case .xcode:       return "DerivedData, Simulators, Archives, Xcode toolchain"
        case .javascript:  return "Node Modules, Metro Cache, npm/Yarn/pnpm"
        case .android:     return "Gradle Cache, Android SDK, Java"
        case .workspace:   return "Projects, stale code, abandoned repos"
        case .environment: return "Installed tools and version health"
        }
    }
}
