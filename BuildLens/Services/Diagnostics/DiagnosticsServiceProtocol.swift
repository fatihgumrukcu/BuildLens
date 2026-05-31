import Foundation

protocol DiagnosticsServiceProtocol: Sendable {
    func generateReport() async throws -> DiagnosticSummary
}
