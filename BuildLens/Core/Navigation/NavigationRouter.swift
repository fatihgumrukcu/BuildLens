import SwiftUI
import Observation

// Owns all navigation state. Lives inside AppState so any feature
// can reach it via @Environment(AppState.self).router.
@Observable
final class NavigationRouter {
    var selectedDestination: AppDestination? = .dashboard
    var columnVisibility: NavigationSplitViewVisibility = .all

    func navigate(to destination: AppDestination) {
        selectedDestination = destination
    }
}
