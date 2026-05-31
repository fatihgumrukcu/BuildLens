import SwiftUI

// Root window shell. Owns only layout — no business logic lives here.
// NavigationSplitView gives us the native macOS three-column (or two-column)
// sidebar+detail pattern that AppKit users expect.
struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var router = appState.router

        NavigationSplitView(columnVisibility: $router.columnVisibility) {
            SidebarView()
        } detail: {
            if let destination = router.selectedDestination {
                DetailRouterView(destination: destination)
                    .id(destination) // forces full view replacement on destination change
            } else {
                EmptySelectionView()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

private struct EmptySelectionView: View {
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "sidebar.left")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.textTertiary)
            Text("Select a section")
                .font(.appTitle3)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
