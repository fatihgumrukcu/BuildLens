import Foundation

struct WorkspaceSummary: Sendable {
    let totalProjects: Int
    let totalWorkspaceStorage: Int64
    let staleProjects: Int
    let reclaimableStorage: Int64
    let largestProject: WorkspaceProject?

    static func build(from projects: [WorkspaceProject]) -> WorkspaceSummary {
        let staleThreshold = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        return WorkspaceSummary(
            totalProjects: projects.count,
            totalWorkspaceStorage: projects.reduce(0) { $0 + $1.totalSize },
            staleProjects: projects.filter { $0.lastModified < staleThreshold }.count,
            reclaimableStorage: projects.reduce(0) { $0 + $1.reclaimableSize },
            largestProject: projects.max(by: { $0.totalSize < $1.totalSize })
        )
    }

    static let empty = WorkspaceSummary(
        totalProjects: 0,
        totalWorkspaceStorage: 0,
        staleProjects: 0,
        reclaimableStorage: 0,
        largestProject: nil
    )
}
