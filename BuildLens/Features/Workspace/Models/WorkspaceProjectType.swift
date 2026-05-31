import Foundation

enum WorkspaceProjectType: String, CaseIterable, Hashable, Sendable {
    case reactNative = "React Native"
    case ios         = "iOS / Xcode"
    case android     = "Android"
    case node        = "Node.js"
    case expo        = "Expo"
    case nextjs      = "Next.js"
    case flutter     = "Flutter"
    case swift       = "Swift Package"
    case unknown     = "Unknown"

    var systemImage: String {
        switch self {
        case .reactNative: return "atom"
        case .ios:         return "hammer"
        case .android:     return "square.stack.3d.down.right"
        case .node:        return "shippingbox"
        case .expo:        return "square.on.square"
        case .nextjs:      return "arrow.trianglehead.2.counterclockwise"
        case .flutter:     return "wind"
        case .swift:       return "swift"
        case .unknown:     return "questionmark.folder"
        }
    }

    var accentColor: String {
        // Returned as string so models stay SwiftUI-free.
        // Views resolve these to Color values.
        switch self {
        case .reactNative: return "blue"
        case .ios:         return "gray"
        case .android:     return "green"
        case .node:        return "green"
        case .expo:        return "purple"
        case .nextjs:      return "primary"
        case .flutter:     return "cyan"
        case .swift:       return "orange"
        case .unknown:     return "secondary"
        }
    }
}
