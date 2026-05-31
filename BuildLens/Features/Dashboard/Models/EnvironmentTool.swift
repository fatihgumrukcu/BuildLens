import Foundation

// Represents one probed developer tool (Xcode, Node, CocoaPods, etc.)
// Value type — safe to pass across concurrency boundaries.
struct EnvironmentTool: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let status: Status
    let version: String?

    enum Status: Equatable, Sendable {
        case installed
        case missing
        case unknown
    }
}
