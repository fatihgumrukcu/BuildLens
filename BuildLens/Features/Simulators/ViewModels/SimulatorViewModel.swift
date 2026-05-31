import Foundation
import Observation

@Observable
@MainActor
final class SimulatorViewModel {

    // MARK: - State

    enum ScanState: Equatable {
        case idle
        case scanning
        case loaded
        case empty
        case error(String)
    }

    private(set) var runtimes: [SimulatorRuntime] = []
    var scanState: ScanState = .idle
    var searchQuery: String = ""

    // MARK: - Derived

    // Recomputed by @Observable whenever runtimes changes — zero extra wiring required.
    var summary: SimulatorSummary {
        let allDevices = runtimes.flatMap { $0.devices }
        return SimulatorSummary(
            totalDevices:       allDevices.count,
            unavailableDevices: allDevices.filter { !$0.isAvailable }.count,
            totalStorageUsage:  runtimes.reduce(0) { $0 + $1.totalStorageUsage },
            activeRuntimeCount: runtimes.filter { $0.isAvailable }.count,
            runningDeviceCount: allDevices.filter { $0.state.isRunning }.count
        )
    }

    // Filters device names within each runtime; empty runtimes are dropped entirely.
    var filteredRuntimes: [SimulatorRuntime] {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return runtimes }
        return runtimes.compactMap { runtime in
            let matched = runtime.devices.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
            guard !matched.isEmpty else { return nil }
            return SimulatorRuntime(
                id:          runtime.id,
                identifier:  runtime.identifier,
                displayName: runtime.displayName,
                version:     runtime.version,
                isAvailable: runtime.isAvailable,
                devices:     matched
            )
        }
    }

    // MARK: - Init

    private let service: SimulatorServiceProtocol

    init(service: SimulatorServiceProtocol = SimulatorService()) {
        self.service = service
    }

    // MARK: - Actions

    func scan() async {
        guard scanState != .scanning else { return }
        scanState = .scanning

        do {
            let results = try await service.fetchRuntimes()
            runtimes = results
            scanState = results.isEmpty ? .empty : .loaded
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        runtimes = []
        scanState = .idle
        await scan()
    }
}
