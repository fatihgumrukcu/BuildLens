import Foundation

protocol XcodeCenterServiceProtocol: Sendable {
    func generateSummary() async throws -> XcodeInfrastructureSummary
}
