import Foundation
import Observation

/// Single source of truth injected at the root via .environment(appState).
/// Features read it via @Environment(AppState.self) and never instantiate it directly.
@Observable
final class AppState {
    var router = NavigationRouter()
}
