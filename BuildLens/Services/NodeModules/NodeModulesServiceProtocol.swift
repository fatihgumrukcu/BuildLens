import Foundation

protocol NodeModulesServiceProtocol: Sendable {
    func scanProjects() async throws -> [NodeModulesProject]
}
