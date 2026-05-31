import Foundation

enum BuildToolCategory: String, CaseIterable, Hashable, Sendable {
    case xcode      = "Xcode & iOS"
    case javascript = "JavaScript / React Native"
    case android    = "Android"
    case system     = "System Tools"

    var systemImage: String {
        switch self {
        case .xcode:      return "hammer.fill"
        case .javascript: return "atom"
        case .android:    return "square.stack.3d.down.right.fill"
        case .system:     return "gearshape.fill"
        }
    }

    var tools: [String] {
        switch self {
        case .xcode:      return ["Xcode", "CocoaPods", "Ruby", "Fastlane"]
        case .javascript: return ["Node.js", "npm", "Yarn", "pnpm", "Watchman"]
        case .android:    return ["Java", "Gradle", "Android SDK", "Android Studio"]
        case .system:     return ["Homebrew"]
        }
    }
}
