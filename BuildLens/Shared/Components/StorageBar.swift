import SwiftUI

// Proportional fill bar used in storage-heavy list rows.
// Shows one item's share of a total — purely visual, no interaction.
// tint defaults to .accentColor so every feature gets brand-consistent coloring
// without needing to pass a custom color.
struct StorageBar: View {
    let proportion: Double   // 0.0 – 1.0
    var tint: Color = .accentColor

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tint.opacity(0.12))
                Capsule()
                    .fill(tint.opacity(0.55))
                    .frame(width: geometry.size.width * max(0.02, min(1.0, proportion)))
            }
        }
        .frame(height: 3)
    }
}
