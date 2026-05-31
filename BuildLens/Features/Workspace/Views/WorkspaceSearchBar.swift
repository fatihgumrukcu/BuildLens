import SwiftUI

struct WorkspaceSearchBar: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(Color.textTertiary)

            TextField("Search projects\u{2026}", text: $query)
                .textFieldStyle(.plain)
                .font(.appCallout)
                .foregroundStyle(Color.textPrimary)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs - 1)
        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder.opacity(0.5), lineWidth: 0.5))
    }
}
