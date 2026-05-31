import Foundation

protocol CleanupServiceProtocol: Sendable {
    func buildPreview() async throws -> CleanupPreview
    func executeCleanup(items: [CleanupItem]) async throws -> CleanupResult
}
