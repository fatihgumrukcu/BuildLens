import SwiftUI

struct SidebarItemView: View {
    let destination: AppDestination

    var body: some View {
        Label(destination.title, systemImage: destination.systemImage)
            .font(.appBody)
    }
}
