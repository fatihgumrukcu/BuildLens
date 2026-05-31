import SwiftUI

@Observable @MainActor
final class CleanupViewModel {

    enum Phase: Equatable {
        case idle
        case scanning
        case preview(CleanupPreview)
        case confirming(CleanupPreview)
        case cleaning
        case result(CleanupResult)
        case error(String)

        static func == (lhs: Phase, rhs: Phase) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.scanning, .scanning), (.cleaning, .cleaning):
                return true
            case (.preview, .preview), (.confirming, .confirming):
                return true
            case (.result, .result):
                return true
            case (.error(let a), .error(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    private(set) var phase: Phase = .idle
    private let service: any CleanupServiceProtocol

    init(service: any CleanupServiceProtocol = CleanupService()) {
        self.service = service
    }

    // MARK: - Derived State

    var currentPreview: CleanupPreview? {
        switch phase {
        case .preview(let p), .confirming(let p): return p
        default: return nil
        }
    }

    // MARK: - Lifecycle

    func scan() async {
        phase = .scanning
        do {
            let preview = try await service.buildPreview()
            phase = preview.items.isEmpty ? .idle : .preview(preview)
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        phase = .idle
        await scan()
    }

    // MARK: - Selection

    func toggleItem(id: UUID) {
        guard case .preview(let preview) = phase else { return }
        var updated = preview.items
        guard let idx = updated.firstIndex(where: { $0.id == id }) else { return }
        updated[idx].isSelected.toggle()
        phase = .preview(CleanupPreview(items: updated, scannedAt: preview.scannedAt))
    }

    func selectAll(in category: CleanupCategory) {
        guard case .preview(let preview) = phase else { return }
        var updated = preview.items
        for i in updated.indices where updated[i].category == category {
            updated[i].isSelected = true
        }
        phase = .preview(CleanupPreview(items: updated, scannedAt: preview.scannedAt))
    }

    func deselectAll(in category: CleanupCategory) {
        guard case .preview(let preview) = phase else { return }
        var updated = preview.items
        for i in updated.indices where updated[i].category == category {
            updated[i].isSelected = false
        }
        phase = .preview(CleanupPreview(items: updated, scannedAt: preview.scannedAt))
    }

    // MARK: - Cleanup Flow

    func requestConfirmation() {
        guard case .preview(let preview) = phase, !preview.selectedItems.isEmpty else { return }
        phase = .confirming(preview)
    }

    func cancelConfirmation() {
        guard case .confirming(let preview) = phase else { return }
        phase = .preview(preview)
    }

    func executeCleanup() async {
        guard case .confirming(let preview) = phase else { return }
        let toDelete = preview.selectedItems
        phase = .cleaning
        do {
            let result = try await service.executeCleanup(items: toDelete)
            phase = .result(result)
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func reset() {
        phase = .idle
    }
}
