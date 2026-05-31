import Foundation

protocol MetroCacheServiceProtocol: Sendable {
    func scanEntries() async throws -> [MetroCacheEntry]
}
