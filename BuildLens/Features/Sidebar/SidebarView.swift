import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var router = appState.router

        List(selection: $router.selectedDestination) {
            ForEach(SidebarCategory.allCases, id: \.self) { category in
                // Skip categories that have no destinations (future-proofing)
                if !category.destinations.isEmpty {
                    Section(category.rawValue) {
                        ForEach(category.destinations) { destination in
                            SidebarItemView(destination: destination)
                                .tag(destination)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: AppSpacing.sidebarMinWidth)
        .navigationTitle("BuildLens")
    }
}
