import SwiftUI

struct CleanupResultView: View {
    let result: CleanupResult
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Status icon
                Image(systemName: result.wasFullSuccess ? "checkmark.circle" : "exclamationmark.triangle")
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundStyle(result.wasFullSuccess ? Color.statusHealthy : Color.statusWarning)
                    .padding(.top, AppSpacing.xxxl)

                VStack(spacing: AppSpacing.xs) {
                    Text(result.wasFullSuccess ? "Cleanup Complete" : "Cleanup Finished with Errors")
                        .font(.appTitle2)
                        .foregroundStyle(Color.textPrimary)

                    Text("Freed \(result.freedBytes.formattedBytes) across \(result.deletedCount) item\(result.deletedCount == 1 ? "" : "s").")
                        .font(.appCallout)
                        .foregroundStyle(Color.textSecondary)
                }

                // Stats row
                HStack(spacing: AppSpacing.lg) {
                    statCard(value: result.freedBytes.formattedBytes, label: "Freed", icon: "minus.circle", tint: .statusHealthy)
                    statCard(value: "\(result.deletedCount)", label: "Deleted", icon: "checkmark.circle", tint: .statusHealthy)
                    if result.failedCount > 0 {
                        statCard(value: "\(result.failedCount)", label: "Failed", icon: "xmark.circle", tint: .statusError)
                    }
                }

                // Failed items
                if !result.failedItems.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Items that could not be deleted")
                            .font(.appHeadline)
                            .foregroundStyle(Color.textPrimary)

                        ForEach(result.failedItems, id: \.item.id) { pair in
                            HStack(alignment: .top, spacing: AppSpacing.xs) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.statusError)
                                    .font(.system(size: 13))
                                    .padding(.top, 2)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pair.item.name)
                                        .font(.appCallout)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(pair.error)
                                        .font(.appFootnote)
                                        .foregroundStyle(Color.textSecondary)
                                }
                            }
                            .padding(AppSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: 520)
                }

                Button("Done", action: onDone)
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, AppSpacing.xxxl)
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.appBackground)
    }

    private func statCard(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(tint)
            Text(value)
                .font(.appTitle2.monospacedDigit())
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.appFootnote)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(minWidth: 100)
        .padding(AppSpacing.md)
        .cardStyle()
    }
}
