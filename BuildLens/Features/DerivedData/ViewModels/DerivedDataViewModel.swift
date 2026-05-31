import Foundation
import Observation

@Observable
@MainActor
final class DerivedDataViewModel {

    // MARK: - State

    enum ScanState: Equatable {
        case idle
        case scanning
        case loaded
        case empty
        case error(String)
    }

    private(set) var items: [DerivedDataItem] = []
    var scanState: ScanState = .idle

    // Derived — recomputed instantly by @Observable when items changes.
    var totalSize: Int64 { items.reduce(0) { $0 + $1.size } }

    // MARK: - Init

    private let fileSystem: FileSystemServiceProtocol

    init(fileSystem: FileSystemServiceProtocol = FileSystemService()) {
        self.fileSystem = fileSystem
    }

    // MARK: - Actions

    func scan() async {
        guard scanState != .scanning else { return }
        scanState = .scanning

        do {
            // scanDirectory spawns a TaskGroup internally — every DerivedData entry
            // gets its size calculated concurrently. No serial blocking.
            let raw = try await fileSystem.scanDirectory(at: FileSystemService.derivedDataPath)
            let mapped = raw.map(DerivedDataItem.init(from:))
            items = mapped
            scanState = mapped.isEmpty ? .empty : .loaded
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        items = []
        scanState = .idle
        await scan()
    }
}
