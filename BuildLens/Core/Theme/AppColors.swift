import SwiftUI

// All semantic colors in one place. Use these everywhere — never raw Color.X
// directly in feature views. Mapping to NSColor ensures correct dark/light mode behavior.
extension Color {
    // Surfaces
    static let appBackground = Color(NSColor.windowBackgroundColor)
    static let appSurface    = Color(NSColor.controlBackgroundColor)
    static let appBorder     = Color(NSColor.separatorColor)

    // Text hierarchy
    static let textPrimary   = Color(NSColor.labelColor)
    static let textSecondary = Color(NSColor.secondaryLabelColor)
    static let textTertiary  = Color(NSColor.tertiaryLabelColor)

    // Status semantics — used across all features for consistent health signals
    static let statusHealthy = Color.green
    static let statusWarning = Color.orange
    static let statusError   = Color.red
    static let statusUnknown = Color(NSColor.secondaryLabelColor)
}
