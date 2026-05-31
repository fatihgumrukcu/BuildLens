import SwiftUI

struct DerivedDataScanningView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Scanning DerivedData\u{2026}")
                .font(.appCallout)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
