import Foundation

// Ordered worst-first so sorted { $0.severity > $1.severity } puts critical at the top.
enum EnvironmentSeverity: Int, Comparable, Hashable, Sendable {
    case healthy  = 0
    case warning  = 1
    case critical = 2

    static func < (lhs: EnvironmentSeverity, rhs: EnvironmentSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .healthy:  return "Healthy"
        case .warning:  return "Warning"
        case .critical: return "Critical"
        }
    }

    var systemImage: String {
        switch self {
        case .healthy:  return "checkmark.circle.fill"
        case .warning:  return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }
}
