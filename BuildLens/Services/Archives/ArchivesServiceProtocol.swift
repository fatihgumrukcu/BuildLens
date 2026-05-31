import Foundation

protocol ArchivesServiceProtocol: Sendable {
    func scanArchives() async throws -> [ArchiveItem]
}
