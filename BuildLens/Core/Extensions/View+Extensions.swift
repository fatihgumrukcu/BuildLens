import SwiftUI

extension View {
    // Standard card shell used by every metric and info card.
    // .regularMaterial gives the frosted-glass depth consistent with macOS system UI.
    func cardStyle() -> some View {
        self
            .padding(AppSpacing.cardPadding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                    .strokeBorder(Color.appBorder.opacity(0.4), lineWidth: 0.5)
            )
    }

    // Standard edge padding for every top-level content scroll area.
    func contentPadding() -> some View {
        self.padding(AppSpacing.contentPadding)
    }
}
