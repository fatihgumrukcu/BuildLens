import SwiftUI

// Coloured dot indicating tool presence. Used by EnvironmentHealthSection
// and future diagnostic views. Status drives color — never set color directly.
struct StatusBadge: View {
    let status: EnvironmentTool.Status

    var body: some View {
        Circle()
            .fill(dotColor)
            .frame(width: 8, height: 8)
    }

    private var dotColor: Color {
        switch status {
        case .installed: return .statusHealthy
        case .missing:   return .statusError
        case .unknown:   return .statusUnknown
        }
    }
}
