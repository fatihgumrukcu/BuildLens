import Foundation

protocol GradleCacheServiceProtocol: Sendable {
    func scanEntries() async throws -> [GradleCacheEntry]
}
