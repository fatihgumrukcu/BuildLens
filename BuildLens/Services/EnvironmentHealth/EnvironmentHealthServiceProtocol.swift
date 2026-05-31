import Foundation

// Non-throwing contract: the health engine always produces a complete report.
// Individual section failures degrade that section's score rather than aborting the report.
// Future AI-backed implementations may extend this protocol with additional methods.
protocol EnvironmentHealthServiceProtocol: Sendable {
    func generateReport() async -> EnvironmentHealthReport
}
