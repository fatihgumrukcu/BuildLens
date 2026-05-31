import Foundation

protocol FileSystemServiceProtocol: Sendable {
    func size(at path: String) async -> Int64
    func exists(at path: String) -> Bool
    func contents(of directory: String) async throws -> [URL]
    // Scans one directory level in parallel: name + allocated size + modification date per child.
    // The workhorse for DerivedData, NodeModules, GradleCache, and Archives features.
    func scanDirectory(at path: String) async throws -> [DirectoryItem]
}
