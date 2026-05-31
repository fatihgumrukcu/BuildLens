import Foundation

enum NodeModulesProjectType: String, CaseIterable, Hashable, Sendable {
    case reactNative = "React Native"
    case expo        = "Expo"
    case nextjs      = "Next.js"
    case node        = "Node.js"

    var systemImage: String {
        switch self {
        case .reactNative: return "atom"
        case .expo:        return "square.on.square"
        case .nextjs:      return "arrow.trianglehead.2.counterclockwise"
        case .node:        return "shippingbox"
        }
    }

    // Returned as a string so the model stays SwiftUI-free.
    // Views resolve these to Color values.
    var accentColor: String {
        switch self {
        case .reactNative: return "blue"
        case .expo:        return "purple"
        case .nextjs:      return "primary"
        case .node:        return "green"
        }
    }

    init?(from workspaceType: WorkspaceProjectType) {
        switch workspaceType {
        case .reactNative: self = .reactNative
        case .expo:        self = .expo
        case .nextjs:      self = .nextjs
        case .node:        self = .node
        default:           return nil
        }
    }
}
