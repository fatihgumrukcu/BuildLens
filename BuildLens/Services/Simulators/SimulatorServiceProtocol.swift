import Foundation

// Defines the boundary between the Simulators feature and the system.
// ViewModels depend on this protocol only — never on SimulatorService directly.
// Phase 4 cleanup methods (delete, erase) will be added here, not retrofitted.
protocol SimulatorServiceProtocol: Sendable {
    func fetchRuntimes() async throws -> [SimulatorRuntime]

    // Phase 4 surface — declared now so architecture is pre-shaped:
    // func deleteSimulator(_ device: SimulatorDevice) async throws
    // func eraseSimulator(_ device: SimulatorDevice) async throws
}
