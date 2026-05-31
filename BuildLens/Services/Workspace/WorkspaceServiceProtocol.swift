import Foundation

protocol WorkspaceServiceProtocol: Sendable {
    func scanProjects() async throws -> [WorkspaceProject]
}
