import SwiftUI

@Observable @MainActor
final class XcodeCenterViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded(XcodeInfrastructureSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle

    private let service: any XcodeCenterServiceProtocol

    init(service: any XcodeCenterServiceProtocol = XcodeCenterService()) {
        self.service = service
    }

    // MARK: - Derived State

    var summary: XcodeInfrastructureSummary? {
        if case .loaded(let s) = scanState { return s }
        return nil
    }

    var isLoaded: Bool {
        if case .loaded = scanState { return true }
        return false
    }

    private(set) var isRescanning = false

    // MARK: - Actions

    func load() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let result = try await service.generateSummary()
            scanState = .loaded(result)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func reload() async {
        guard !isRescanning else { return }
        isRescanning = true
        defer { isRescanning = false }
        do {
            let result = try await service.generateSummary()
            scanState = .loaded(result)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }
}
