import Foundation

enum XcodeStorageCategory: String, CaseIterable, Hashable, Sendable {
    case derivedData       = "DerivedData"
    case archives          = "Archives"
    case simulators        = "Simulators"
    case deviceSupport     = "Device Support"
    case documentationCache = "Documentation"

    var systemImage: String {
        switch self {
        case .derivedData:       return "hammer.fill"
        case .archives:          return "archivebox.fill"
        case .simulators:        return "iphone.gen1"
        case .deviceSupport:     return "cable.connector"
        case .documentationCache: return "book.closed.fill"
        }
    }

    var accentColor: String {
        switch self {
        case .derivedData:       return "blue"
        case .archives:          return "orange"
        case .simulators:        return "teal"
        case .deviceSupport:     return "green"
        case .documentationCache: return "purple"
        }
    }

    var description: String {
        switch self {
        case .derivedData:        return "Build artifacts rebuilt by Xcode on next compile"
        case .archives:           return "Exported .xcarchive bundles for distribution"
        case .simulators:         return "Simulator device data and runtime images"
        case .deviceSupport:      return "Device symbol files for connected iOS devices"
        case .documentationCache: return "Cached developer documentation"
        }
    }
}

struct XcodeStorageSection: Identifiable, Hashable, Sendable {
    var id: XcodeStorageCategory { category }
    let category: XcodeStorageCategory
    let size: Int64
    let itemCount: Int
    let reclaimableStorage: Int64
}
