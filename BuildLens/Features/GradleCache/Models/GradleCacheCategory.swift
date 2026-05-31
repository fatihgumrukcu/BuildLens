import Foundation

enum GradleCacheCategory: String, CaseIterable, Hashable, Sendable {
    case caches  = "Caches"
    case wrapper = "Wrapper"
    case daemon  = "Daemon"
    case native  = "Native"
    case jdks    = "JDKs"

    var systemImage: String {
        switch self {
        case .caches:  return "square.stack.3d.down.right.fill"
        case .wrapper: return "shippingbox.fill"
        case .daemon:  return "gearshape.2.fill"
        case .native:  return "cpu"
        case .jdks:    return "chevron.left.forwardslash.chevron.right"
        }
    }

    // Human-readable description for the detail view.
    var description: String {
        switch self {
        case .caches:
            return "Dependency JARs, transformed artifacts, and version-specific build caches"
        case .wrapper:
            return "Downloaded Gradle distributions — one per Gradle version in use"
        case .daemon:
            return "Gradle daemon process logs and registry files"
        case .native:
            return "Platform-specific native libraries required by the Gradle toolchain"
        case .jdks:
            return "Auto-provisioned JDK toolchains downloaded by Gradle toolchain support"
        }
    }

    // Tint color name (resolved to Color in Views).
    var accentColor: String {
        switch self {
        case .caches:  return "blue"
        case .wrapper: return "green"
        case .daemon:  return "purple"
        case .native:  return "orange"
        case .jdks:    return "teal"
        }
    }
}
