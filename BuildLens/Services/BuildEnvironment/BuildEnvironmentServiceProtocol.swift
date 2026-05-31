import Foundation

protocol BuildEnvironmentServiceProtocol: Sendable {
    func scan() async throws -> BuildEnvironmentSummary
}
