import SwiftUI

// The single dispatch point between navigation selection and feature views.
// Pattern: one switch, one case per destination, no logic.
// Adding a new screen = add a case here + add the view file in its feature folder.
struct DetailRouterView: View {
    let destination: AppDestination

    var body: some View {
        switch destination {
        case .dashboard:
            DashboardView()
        case .environmentHealth:
            EnvironmentHealthView()
        case .workspaceIntelligence:
            WorkspaceView()
        case .derivedData:
            DerivedDataView()
        case .simulators:
            SimulatorView()
        case .cleanupEngine:
            CleanupView()
        case .nodeModules:
            NodeModulesView()
        case .metroCache:
            MetroCacheView()
        default:
            PlaceholderFeatureView(destination: destination)
        }
    }
}
