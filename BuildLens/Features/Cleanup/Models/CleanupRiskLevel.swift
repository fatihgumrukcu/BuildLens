import Foundation

enum CleanupRiskLevel: Int, Comparable, Sendable {
    case safe = 0
    case moderate = 1
    case caution = 2

    static func < (lhs: CleanupRiskLevel, rhs: CleanupRiskLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .safe:     return "Safe"
        case .moderate: return "Moderate"
        case .caution:  return "Caution"
        }
    }

    var detail: String {
        switch self {
        case .safe:     return "Regenerated automatically by developer tools."
        case .moderate: return "Rebuilding may slow down your next build or run."
        case .caution:  return "Review carefully. May require manual steps to restore."
        }
    }
}
