import SwiftUI

struct CleanupView: View {
    @State private var viewModel = CleanupViewModel()

    var body: some View {
        Group {
            switch viewModel.phase {
            case .idle:
                CleanupEmptyView(onScan: { Task { await viewModel.scan() } })

            case .scanning:
                CleanupProgressView(message: "Scanning developer caches\u{2026}")

            case .preview(let preview):
                CleanupDashboardView(viewModel: viewModel, preview: preview)

            case .confirming(let preview):
                CleanupDashboardView(viewModel: viewModel, preview: preview)
                    .sheet(isPresented: .constant(true)) {
                        CleanupConfirmationSheet(
                            preview: preview,
                            onConfirm: { Task { await viewModel.executeCleanup() } },
                            onCancel: { viewModel.cancelConfirmation() }
                        )
                    }

            case .cleaning:
                CleanupProgressView(message: "Cleaning\u{2026}")

            case .result(let result):
                CleanupResultView(result: result, onDone: { viewModel.reset() })

            case .error(let message):
                CleanupErrorView(message: message, onRetry: { Task { await viewModel.rescan() } })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await viewModel.scan() }
    }
}
