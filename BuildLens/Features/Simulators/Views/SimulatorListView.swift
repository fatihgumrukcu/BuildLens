import SwiftUI

// Grouped list: one Section per runtime, disclosure triangles are native macOS behavior.
// Receives already-filtered runtimes from the ViewModel — no filtering logic here.
struct SimulatorListView: View {
    let runtimes: [SimulatorRuntime]

    var body: some View {
        if runtimes.isEmpty {
            noResultsView
        } else {
            List {
                ForEach(runtimes) { runtime in
                    Section {
                        ForEach(runtime.devices) { device in
                            SimulatorDeviceRowView(device: device)
                        }
                    } header: {
                        SimulatorRuntimeSectionView(runtime: runtime)
                    }
                }
            }
            .listStyle(.inset)
        }
    }

    private var noResultsView: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(Color.textTertiary)
            Text("No simulators match your search")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
