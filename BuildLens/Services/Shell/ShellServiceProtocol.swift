import Foundation

// Protocol-first design: ViewModels depend on this, never on ShellService directly.
// This makes testing trivial — inject a mock conformer without touching feature code.
protocol ShellServiceProtocol: Sendable {
    func run(_ command: String) async throws -> String
    func which(_ tool: String) async throws -> String
}
