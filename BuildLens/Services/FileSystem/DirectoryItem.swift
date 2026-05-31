import Foundation

// Generic result of scanning one level of a directory.
// DerivedData, NodeModules, GradleCache, and Archives all map this to their own
// domain model — FileSystemService stays feature-agnostic.
struct DirectoryItem: Identifiable, Hashable, Sendable {
    let id: URL
    let url: URL
    let name: String
    let size: Int64
    let lastModified: Date
}
