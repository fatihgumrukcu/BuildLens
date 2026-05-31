import Foundation

enum CleanupCategory: String, CaseIterable, Hashable, Sendable {
    case derivedData          = "DerivedData"
    case simulators           = "Simulators"
    case runtimes             = "Runtimes"
    case metroCache           = "Metro Cache"
    case gradleCache          = "Gradle Cache"
    case cocoapods            = "CocoaPods Cache"
    case archives             = "Xcode Archives"
    case watchman             = "Watchman Cache"
    case androidBuildOutputs  = "Android Build Outputs"

    var systemImage: String {
        switch self {
        case .derivedData:         return "hammer"
        case .simulators:          return "iphone"
        case .runtimes:            return "square.stack.3d.down.right"
        case .metroCache:          return "bolt"
        case .gradleCache:         return "square.stack.3d.down.right.fill"
        case .cocoapods:           return "shippingbox"
        case .archives:            return "archivebox"
        case .watchman:            return "eye.slash"
        case .androidBuildOutputs: return "wrench.and.screwdriver"
        }
    }

    var riskLevel: CleanupRiskLevel {
        switch self {
        case .derivedData:         return .safe
        case .simulators:          return .moderate
        case .runtimes:            return .caution
        case .metroCache:          return .safe
        case .gradleCache:         return .safe
        case .cocoapods:           return .safe
        case .archives:            return .caution
        case .watchman:            return .safe
        case .androidBuildOutputs: return .safe
        }
    }

    var hint: String {
        switch self {
        case .derivedData:
            return "Rebuilt automatically on next build. Safe to delete any time."
        case .simulators:
            return "Removes simulator device data. Reinstalling apps will be required."
        case .runtimes:
            return "Removes downloaded OS images. Re-downloading from Xcode will be required."
        case .metroCache:
            return "Rebuilt on next `npx react-native start`. No data lost."
        case .gradleCache:
            return "Dependencies are re-downloaded from Maven/Gradle on the next Android build."
        case .cocoapods:
            return "Re-downloaded on the next `pod install` run."
        case .archives:
            return "Exported .xcarchive bundles. These cannot be recovered once deleted."
        case .watchman:
            return "Watchman file-watch state. Automatically rebuilt when Watchman restarts."
        case .androidBuildOutputs:
            return "APKs, AABs, native .so libraries, and compiled classes inside project build/ folders. Fully regenerated on the next Android/React Native build."
        }
    }
}
