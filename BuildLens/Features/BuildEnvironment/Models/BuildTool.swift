import Foundation

enum BuildToolStatus: Equatable, Hashable, Sendable {
    case installed
    case missing
    case outdated   // installed but below minimum recommended version
    case unknown
}

struct BuildTool: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let category: BuildToolCategory
    let status: BuildToolStatus
    let version: String?     // raw version string from shell/plist
    let path: String?        // install path from `which` or filesystem
    let issues: [BuildToolIssue]

    // MARK: - Derived

    var isInstalled: Bool { status == .installed || status == .outdated }
    var isMissing: Bool   { status == .missing }

    var healthSeverity: EnvironmentSeverity {
        if status == .missing  { return .warning  }
        if status == .outdated { return .warning  }
        if !issues.isEmpty     { return .warning  }
        return .healthy
    }

    // Maps to the existing StatusBadge dot (installed/missing/unknown).
    var legacyStatus: EnvironmentTool.Status {
        switch status {
        case .installed, .outdated: return .installed
        case .missing:              return .missing
        case .unknown:              return .unknown
        }
    }

    var abbreviatedPath: String? {
        path?.abbreviatedPath
    }
}
